#################### CodePipeline 아티팩트 저장 S3 ####################
resource "aws_s3_bucket" "jh_s3_codepipeline" {
  bucket = "jh-s3-codepipeline"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "CodePipelineArtifacts"
    Environment = "Dev"
  }
}

#################### CodePipeline Role ####################
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

#################### CodePipeline Policy ####################
resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

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
