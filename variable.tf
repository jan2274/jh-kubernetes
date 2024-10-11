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
  default = "t2.medium"
}