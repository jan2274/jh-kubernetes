output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
  value = aws_eks_cluster.main.version
}

output "eks_node_group_name" {
  value = aws_eks_node_group.node_group.node_group_name
}

output "eks_node_group_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "aws_eks_cluster" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_ca" {
  value = aws_eks_cluster.main.certificate_authority.0.data
}

# output "ecr_repository_uri" {
#   value       = aws_ecr_repository.ecr_repo.repository_url
#   description = "The URI of the ECR repository"
# }

# output "ecr_uri" {
#   value = var.ecr_repository_uri
# }