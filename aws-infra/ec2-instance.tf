# NAT Instance 생성
resource "aws_instance" "nat" {
  ami           = "ami-0abcdef1234567890"
  instance_type = var.instance_type2
  subnet_id     = aws_subnet.public[0].id
  
  # 필요한 IAM 역할이 있으면 추가
  associate_public_ip_address = true

  tags = {
    Name = "jh-nat-instance"
  }
}

# NAT 인스턴스에 대한 보안 그룹 설정
resource "aws_security_group" "nat_sg" {
  vpc_id = aws_vpc.main.id

  # 아웃바운드 트래픽을 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 프라이빗 서브넷의 인스턴스에서 접근을 허용하는 인바운드 규칙
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = var.private_subnet_cidrs
  }

  tags = {
    Name = "jh-nat-sg"
  }
}

# 프라이빗 서브넷에 대한 라우트 테이블 업데이트
resource "aws_route" "nat_route" {
  count          = length(var.private_subnet_cidrs)
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  instance_id = aws_instance.nat.id
}
