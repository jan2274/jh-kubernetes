######################## 보안 그룹 ########################
# EKS 클러스터 보안 그룹
# resource "aws_security_group" "eks_cluster_sg" {
#   name        = "eks-cluster-sg"
#   description = "Security group for EKS Cluster"
#   vpc_id      = aws_vpc.main.id

#   # EKS 클러스터 -> 노드로의 통신 허용 (TCP 443)
#   ingress {
#     description = "Allow worker node communication"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.main.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "eks-cluster-sg"
#   }
# }

resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS Cluster"
  vpc_id      = aws_vpc.main.id

  # 인바운드 규칙: 모든 트래픽 허용
  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 규칙: 모든 트래픽 허용
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}

# # EKS 노드 그룹 보안 그룹
# resource "aws_security_group" "eks_node_sg" {
#   name        = "eks-node-sg"
#   description = "Security group for EKS Worker Nodes"
#   vpc_id      = aws_vpc.main.id

#   # 노드 -> 클러스터로의 통신 허용 (TCP 443)
#   ingress {
#     description = "Allow cluster communication"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.main.cidr_block]
#   }

#   # 외부에서의 SSH 접근 허용 (TCP 22)
#   ingress {
#     description = "Allow SSH access from outside"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # EKS 노드 간 통신 허용
#   ingress {
#     description = "Allow node-to-node communication"
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.main.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "eks-node-sg"
#   }
# }

# EKS 노드 그룹 보안 그룹
resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "Security group for EKS Worker Nodes"
  vpc_id      = aws_vpc.main.id

  # 인바운드 규칙: 모든 트래픽 허용
  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 규칙: 모든 트래픽 허용
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-sg"
  }
}


######################## eks 클러스터 ########################
# eks 클러스터 역할 (IAM Role)
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks_cluster_role.name
# }
resource "aws_iam_role_policy_attachment" "AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.eks_cluster_role.name
}

# eks 클러스터 생성
resource "aws_eks_cluster" "main" {
  name     = "jh-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  tags = {
    Name = "jh-eks-cluster"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AdministratorAccess,
  ]
#   depends_on = [
#     aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
#   ]
}

######################## 노드 그룹 ########################
# eks 노드 그룹 역할 (IAM Role)
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AdministratorAccess2" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.eks_node_role.name
}
# resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.eks_node_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.eks_node_role.name
# }


# eks 노드 그룹 생성
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "jh-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = [var.instance_type]

    # 노드 그룹에 보안 그룹 추가
  remote_access {
    ec2_ssh_key          = "jh-key-nodegroup"
    source_security_group_ids = [aws_security_group.eks_node_sg.id]
  }

  tags = {
    Name = "jh-eks-node-group"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.AdministratorAccess2
  ]
#   depends_on = [
#     aws_eks_cluster.main,
#     aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly
#   ]  
}
