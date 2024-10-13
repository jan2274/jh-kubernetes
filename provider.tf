provider "aws" {
    version = "5.70"
    region = "ap-northeast-2"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.main.token

}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}
