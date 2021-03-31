resource "aws_vpc" "new_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = map(
    "Name", "terraform-eks-new-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "new_sub" {
   count = 2

   availability_zone = data.aws_availability_zones.available.names[count.index]
   cidr_block       = "10.0.${count.index}.0/24"
   vpc_id           = aws_vpc.new_vpc.id

   tags = map (
     "Name", "terraform-eks-new-node - ${count.index + 1}"",
     "kubernates.io/cluster/${var.cluster-name}", "shared",
   )
}

resource "aws_internet_gateway" "new_gw" {
   vpc_id = aws_vpc.new_vpc.id

   tags = {
     Name = "terraform-eks-internet-gw"
   }
}

resource "aws_route_table" "new_rte" {
   vpc_id = aws_vpc.new_vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.new_gw.id
   }
}