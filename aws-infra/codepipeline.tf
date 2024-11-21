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

#################### 코드파이프라인한테 버킷한테의 접근 권한 부여 ####################
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
          "arn:aws:s3:::jh-s3-codepipeline",
          "arn:aws:s3:::jh-s3-codepipeline/*"
        ]
      }
    ]
  })
}

#################### 코드파라에게 코드빌드 실행 권한 부여 ####################
resource "aws_iam_role_policy" "codepipeline_codebuild_policy" {
  name = "CodePipeline_CodeBuildPolicy"
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
        Resource = "arn:aws:iam::381492128216:role/codebuild-role"
      }
    ]
  })
}

# resource "aws_iam_policy" "codepipelinecodebuild_policy" {
#   name = "CodePipelineCodeBuildPolicy"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "codebuild:StartBuild",
#           "codebuild:BatchGetBuilds",
#           "codebuild:BatchGetProjects"
#         ],
#         Resource = "arn:aws:iam::381492128216:role/codebuild-role"
#       }
#     ]
#   })
# }



#################### 일단 제거해도 되는것으로 보임 ####################
# resource "aws_iam_role_policy_attachment" "s3_policy" {
#   role       = aws_iam_role.codepipeline_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }

# resource "aws_iam_policy" "codepipeline_s3_policy" {
#   name = "codepipeline-s3-access"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
#         Resource = [
#           "arn:aws:s3:::jh-s3-codebuild",
#           "arn:aws:s3:::jh-s3-codebuild/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "codepipeline_s3_policy_attachment" {
#   role       = aws_iam_role.codepipeline_role.name
#   policy_arn = aws_iam_policy.codepipeline_s3_policy.arn
# }

#################### 생성한 CodePipeline Role에 CodePipeline Policy 부여 ####################
resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

# resource "aws_iam_role_policy_attachment" "codepipeline_policy2" {
#   role       = aws_iam_role.codepipeline_role.name
#   policy_arn = "arn:aws:iam::aws:policy/codepipelinecodebuild_policy"
# }

#################### CodePipeline Resource ####################
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