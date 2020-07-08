data "aws_availability_zones" "available-zone" {
  state = "available"
}

resource "aws_vpc" "eks-cluster-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name                                        = "eks",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks-cluster-vpc.id
  tags = {
    Name = var.cluster_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks-cluster-vpc.id

  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks"
  }
}

resource "aws_subnet" "eks-cluster-subnet" {
  count                   = length(data.aws_availability_zones.available-zone.zone_ids)
  availability_zone       = data.aws_availability_zones.available-zone.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.eks-cluster-vpc.cidr_block, 8, count.index)
  vpc_id                  = aws_vpc.eks-cluster-vpc.id
  map_public_ip_on_launch = "true"
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_route_table_association" "a" {
  count          = length(aws_subnet.eks-cluster-subnet)
  subnet_id      = aws_subnet.eks-cluster-subnet[count.index].id
  route_table_id = aws_route_table.public.id
}
