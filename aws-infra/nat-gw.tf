# # Elastic IP 생성 (NAT Gateway에 할당할 EIP)
# resource "aws_eip" "nat_eip" {
#   vpc = true
#   tags = {
#     Name = "nat-gateway-eip"
#   }
# }

# # NAT Gateway 생성
# resource "aws_nat_gateway" "nat_gateway" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = aws_subnet.public[0].id
#   tags = {
#     Name = "nat-gateway"
#   }
# }

# # 프라이빗 서브넷에 대한 라우트 테이블 업데이트 (NAT Gateway 사용)
# resource "aws_route" "private_route" {
#   route_table_id         = aws_route_table.private.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat_gateway.id
# }


# code build에서 스크립트 실행을 위해 생성하는 인스턴스는 공인IP를 갖지 못하기 떄문에
# private에 인스턴스를 생성하도록 하고 public에 NAT GW를 생성하여 외부와의 통신을 허용한다.
# 이를 위해 NAT GW를 생성하는 코드
######################
# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = 1
  vpc   = true

  tags = {
    Name = "jh-eip-nat-${count.index + 1}"
  }
}

# NAT Gateway in Public Subnet
resource "aws_nat_gateway" "nat" {
  count                   = 1
  allocation_id           = aws_eip.nat[0].id
  subnet_id               = aws_subnet.public[0].id  # NAT 게이트웨이를 첫 번째 퍼블릭 서브넷에 배치
  connectivity_type       = "public"

  tags = {
    Name = "jh-nat-gateway-${count.index + 1}"
  }
}

# Update Private Route Table to Use NAT Gateway
resource "aws_route" "private" {
  count                  = length(aws_subnet.private)
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}
