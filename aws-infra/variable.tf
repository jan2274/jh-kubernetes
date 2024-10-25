variable "region" {
  default = "ap-northeast-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "az" {
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}
variable "public_subnet_cidrs" {
  default = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.32.0/20", "10.0.48.0/20"]
}

variable "instance_type" {
  default = "t2.small"
}

variable "instance_type2" {
  default = "t2.micro"
}

variable "db_passwd" {
  type = string
  # terraform cloud에 sensitive로 값을 저장하여 외부 노출 방지
}

variable "ecr_repository_uri" {
  default       = aws_ecr_repository.ecr_repo.repository_url
  description = "The URI of the ECR repository"
}