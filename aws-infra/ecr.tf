resource "aws_ecr_repository" "ecr_repo" {
  name = "ecr-nginx"

  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
