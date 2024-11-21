#################### CodePipeline 아티팩트 저장 버킷 생성 ####################
resource "aws_s3_bucket" "jh_s3_codepipeline" {
  bucket = "jh-s3-codepipeline"
  acl    = "private"

  tags = {
    Name        = "CodePipelineArtifacts"
  }
}

resource "aws_s3_bucket_versioning" "versioning_s3_codepipeline" {
  bucket = aws_s3_bucket.jh_s3_codepipeline.id
  versioning_configuration {
    status = "Enabled"
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
          "${aws_s3_bucket.jh_s3_codepipeline.arn}",
          "${aws_s3_bucket.jh_s3_codepipeline.arn}/*"
        ]
      }
    ]
  })
}


#################### CodePipeline Role 생성 ####################
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#################### 생성된 CodePipeline Role에게 CodePipeline Policy 부여 ####################
resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

#################### codepipeline에게 codebuild 실행 권한 부여 ####################
resource "aws_iam_role_policy" "codepipeline_codebuild_policy" {
  name = "CodePipelineCodeBuildPolicy"
  role = aws_iam_role.codepipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:BatchGetProjects"
        ],
        # Resource = "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.current.account_id}:project/codebuild-imagebuild"
        Resource = "arn:aws:codebuild:ap-northeast-2:381492128216:project/codebuild-imagebuild"
      }
    ]
  })
}

#################### codepipeline한테 두 버킷한테의 접근 권한 부여 ####################
resource "aws_iam_role_policy" "codepipeline_s3_policy" {
  name = "CodePipelineS3Policy"
  role = aws_iam_role.codepipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.jh_s3_codepipeline.arn}",
          "${aws_s3_bucket.jh_s3_codepipeline.arn}/*",
          "${aws_s3_bucket.jh_s3_codebuild.arn}",
          "${aws_s3_bucket.jh_s3_codebuild.arn}/*"
        #   "arn:aws:s3:::jh-s3-codepipeline",
        #   "arn:aws:s3:::jh-s3-codepipeline/*"
        ]
      }
    ]
  })
}


#################### CodePipeline Resource ####################
resource "aws_codepipeline" "pipeline" {
  name     = "codepipeline-image-build"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.jh_s3_codepipeline.id
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
}