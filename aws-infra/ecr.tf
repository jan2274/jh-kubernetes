resource "aws_ecr_repository" "ecr_repo" {
  name = "ecr-codebuild"

  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}



# locals {
#   region     = data.aws_region.current.name
#   ecr_domain = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
# }

# output "ecr_domain" {
#   value = local.ecr_domain
# }

# output "ecr_region" {
#   value = local.region
# }

# output "ecr_name" {
#   value = aws_ecr_repository.ecr_repo.name
# }