# provider "kubernetes" {
#   host                   = aws_eks_cluster.main.endpoint
#   cluster_ca_certificate = var.cluster_ca_certificate
#   token                  = data.aws_eks_cluster_auth.main.token
# }

# data "aws_eks_cluster_auth" "main" {
#   name = aws_eks_cluster.main.name
# }

data "terraform_remote_state" "eks" {
  backend = "remote"  # Terraform Cloud 백엔드를 가리킴
  config = {
    organization = "jh-kubernetes"  # Terraform Cloud 조직 이름
    workspaces = {
      name = "eks"  # EKS 클러스터가 관리되는 워크스페이스 이름
    }
  }
}

provider "aws" {
    version = "5.70"
    region = "ap-northeast-2"
}

# Kubernetes provider 설정
provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
  cluster_ca_certificate = var.cluster_ca_certificate
  token                  = data.aws_eks_cluster_auth.main.token
}

data "aws_eks_cluster_auth" "main" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_name
}
