resource "aws_vpc" "practical_vpc" {
  cidr_block = var.cidr
  tags = merge(var.tags, {
    Name = "practice_vpc"
    }

  )
}

resource "aws_subnet" "practical_private_subnet" {
  count             = length(var.availability_zone)
  vpc_id            = aws_vpc.practical_vpc.id
  cidr_block        = cidrsubnet(var.cidr, 8, count.index)
  availability_zone = element(var.availability_zone, count.index)

  tags = merge(var.tags, {
    Name = format("%s-practice_private_subnet-${count.index}", var.tags["id"])
    }
  )
}

resource "aws_subnet" "practical_public_subnet" {
  count      = length(var.availability_zone)
  vpc_id     = aws_vpc.practical_vpc.id
  cidr_block = cidrsubnet(var.cidr, 6, count.index + 1)

  tags = merge(var.tags, {
    Name = format("%s-practice_public_subnet-${count.index}", var.tags["id"])
    }
  )
}

resource "aws_internet_gateway" "practical_igw" {
  vpc_id = aws_vpc.practical_vpc.id

  tags = merge(var.tags, {
    Name = format("%s-practice_igw", var.tags["id"])
    }
  )
}

resource "aws_eip" "practical_eip" {
  count = length(var.availability_zone)
  vpc   = true
  tags = merge(var.tags, {
    Name = format("%s-practice_eip-${count.index}", var.tags["id"])
    }
  )
  depends_on = [aws_internet_gateway.practical_igw]
}

resource "aws_nat_gateway" "practical_nat_gateway" {
  count         = length(var.availability_zone)
  allocation_id = element(aws_eip.practical_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.practical_public_subnet.*.id, count.index)

  tags = merge(var.tags, {
    Name = format("%s-practice_nat_gateway-${count.index}", var.tags["id"])
    }
  )

  depends_on = [aws_internet_gateway.practical_igw]
}

resource "aws_route_table" "practical_rt_public" {
  vpc_id = aws_vpc.practical_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.practical_igw.id
  }

  tags = merge(var.tags, {
    Name = format("%s-practice_public_rt", var.tags["id"])
    }
  )
}
resource "aws_route_table_association" "practical_rt_associate" {
  count          = length(var.availability_zone)
  subnet_id      = element(aws_subnet.practical_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.practical_rt_public.id
}

resource "aws_route_table" "practical_rt_private" {
  count                  = length(var.availability_zone)
  vpc_id = aws_vpc.practical_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.practical_nat_gateway.*.id, count.index)
  }

  tags = merge(var.tags, {
    Name = format("%s-practice_private_rt-${count.index}", var.tags["id"])
    }
  )
}
resource "aws_route_table_association" "practical_private_rt_associate" {
  count          = length(var.availability_zone)
  subnet_id      = element(aws_subnet.practical_private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.practical_rt_private.*.id, count.index)
}