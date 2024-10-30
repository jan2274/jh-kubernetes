# NAT 인스턴스 생성
resource "aws_instance" "nat" {
  ami                    = "ami-02c329a4b4aba6a48" # NAT 인스턴스 AMI ID
  instance_type          = var.instance_type2
  subnet_id              = aws_subnet.public[0].id
  associate_public_ip_address = true
  source_dest_check      = false # NAT 인스턴스에서는 Source/Destination 체크 비활성화

  tags = {
    Name = "jh-nat-instance"
  }
}

# NAT 인스턴스에 대한 보안 그룹 설정
resource "aws_security_group" "nat_sg" {
  vpc_id = aws_vpc.main.id

  # 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 프라이빗 서브넷에서 NAT 인스턴스로의 인바운드 트래픽 허용
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnet_cidrs
  }

  tags = {
    Name = "jh-nat-sg"
  }
}

# 프라이빗 서브넷에 대한 라우트 테이블 업데이트 (NAT 인스턴스의 네트워크 인터페이스 사용)
resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}
