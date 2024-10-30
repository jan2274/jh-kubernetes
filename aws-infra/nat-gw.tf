# code build에서 스크립트 실행을 위해 생성하는 인스턴스는 공인IP를 갖지 못하기 떄문에
# private에 인스턴스를 생성하도록 하고 public에 NAT GW를 생성하여 외부와의 통신을 허용한다.
# 이를 위해 NAT GW를 생성하는 코드
######################
# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = 1
  vpc   = true

  tags = {
    Name = "jh-eip-nat"
  }
}

# NAT Gateway in Public Subnet
resource "aws_nat_gateway" "nat" {
  allocation_id           = aws_eip.nat[0].id
  subnet_id               = aws_subnet.public[0].id  # NAT 게이트웨이를 첫 번째 퍼블릭 서브넷에 배치
  connectivity_type       = "public"

  tags = {
    Name = "jh-nat-gateway"
  }
}

# # Update Private Route Table to Use NAT Gateway
# resource "aws_route" "private" {
#   route_table_id         = aws_route_table.private.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat[0].id
# }
