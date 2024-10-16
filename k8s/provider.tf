provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = var.cluster_ca_certificate
  token                  = data.aws_eks_cluster_auth.main.token
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

# provider "kubernetes" {
#   host                   = aws_eks_cluster.main.endpoint
#   cluster_ca_certificate = var.cluster_ca_certificate
#   token                  = data.aws_eks_cluster_auth.main.token
# }

# data "aws_eks_cluster_auth" "main" {
#   name = aws_eks_cluster.main.name
# }