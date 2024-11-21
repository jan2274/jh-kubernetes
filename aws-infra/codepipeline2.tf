# resource "aws_s3_bucket" "jh_s3_codepipeline" {
#   bucket = "jh-s3-codepipeline"
# }

# resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
#   bucket = aws_s3_bucket.jh_s3_codepipeline.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

#################### CodePipeline 아티팩트 저장 S3 ####################
resource "aws_s3_bucket" "jh_s3_codepipeline" {
  bucket = "jh-s3-codepipeline"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "CodePipelineArtifacts"
  }
}

#################### 버킷에게 codepipeline에서 버킷에 권한을 부여하는 정책을 추가 ####################
resource "aws_s3_bucket_policy" "jh_s3_codepipeline_policy" {
  bucket = aws_s3_bucket.jh_s3_codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/codepipeline-role"
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::jh-s3-codepipeline",
          "arn:aws:s3:::jh-s3-codepipeline/*"
        ]
      }
    ]
  })
}

resource "aws_codestarconnections_connection" "codepipeline_connections" {
  name          = "codepipeline-connections"
  provider_type = "GitHub"
}

data "aws_iam_policy_document" "codepipeline_assume_role_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_doc.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"
    actions   = ["codepipeline-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.codepipeline_connections.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }


  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.jh_s3_codepipeline.arn,
      "${aws_s3_bucket.jh_s3_codepipeline.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

# data "aws_kms_alias" "s3kmskey" {
#   name = "alias/myKmsKey"
# }

##############################################################################
resource "aws_codepipeline" "pipeline" {
  name     = "codepipeline-image-build"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.s3_codebuild.id
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner  = "jan2274"
        Repo   = "jh-kubernetes"
        Branch = "main"
        OAuthToken = var.github_oauth_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_imagebuild.name
      }
    }
  }

#   stage {
#     name = "Deploy"

#     action {
#       name             = "DeployToECR"
#       category         = "Deploy"
#       owner            = "AWS"
#       provider         = "ECR"
#       version          = "1"
#       input_artifacts  = ["build_output"]

#       configuration = {
#         RepositoryName = aws_ecr_repository.ecr_repo.name
#         ImageTag       = "latest"
#       }
#     }
#   }
}
