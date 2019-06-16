/* # aws credentials details

provider "aws" {
access_key = "${var.access_key}"
secret_key = "${var.secret_key}"
region = "${var.region}"
}

# the resource to create Management VPC

resource "aws_vpc" "mgmt_vpc" {
  cidr_block  = "${var.management_vpc_cidr}"
  instance_tenancy = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support = "${var.enable_dns_support}"
  tags = "${merge(var.tags, map("Name", format("%s-mngmt-vpc", var.name)))}"

}

# the resource to create public subnets in Management VPC

 resource "aws_subnet" "mngmt_public_subnet" {
  #count = "${length(var.public_subnets_mngmt)}"
  vpc_id   = "${aws_vpc.mgmt_vpc.id}"
  cidr_block = "${var.public_subnets_mngmt}"
  map_public_ip_on_launch = true
  tags = "${merge(var.tags, var.public_subnet_tags, map("Name", format("Mangement-subnet-public-%s",var.public_subnets_mngmt)))}"

}

# the resource to create private subnets in Management VPC

 resource "aws_subnet" "mngmt_private_subnet" {
  #count = "${length(var.private_subnets_mngmt)}"
  vpc_id   = "${aws_vpc.mgmt_vpc.id}"
  cidr_block = "${var.private_subnets_mngmt}"
  tags = "${merge(var.tags, var.private_subnet_tags, map("Name", format("Mangement-subnet-private-%s",var.private_subnets_mngmt)))}"
}

# the resource to create an internet gateway for Management VPC

resource "aws_internet_gateway" "mngmt_igw" {
  #count = "${length(var.public_subnets_mngmt) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.mgmt_vpc.id}"
  tags = "${merge(var.tags, map("Name", format("%s-mngmt-igw", var.name)))}"
}

# the resource to create the public route table in Management VPC

resource "aws_route_table" "mngmt_publicrt" {
  #count = "${length(var.public_subnets_mngmt) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.mgmt_vpc.id}"
  tags = "${merge(var.tags, map("Name", format("%s-mngmt-routetable-public", var.name)))}"
}

# the resource to create the private route table in Management VPC

resource "aws_route_table" "mngmt_privatert" {
  #count = "${length(var.private_subnets_mngmt) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.mgmt_vpc.id}"
  tags = "${merge(var.tags, map("Name", format("%s-mngmt-routetable-private", var.name)))}"
}

# Adding routes to the public route table

resource "aws_route" "mngmt_public_routes" {
  #count = "${length(var.public_subnets_mngmt) > 0 ? 1 : 0}"
  route_table_id         = "${aws_route_table.mngmt_publicrt.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.mngmt_igw.id}"
}

# Public Route Table Association

resource "aws_route_table_association" "mngmt_public" {
  count = "${length(var.public_subnets_mngmt)}"
  subnet_id      = "${element(aws_subnet.mngmt_public_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.mngmt_publicrt.*.id, count.index)}"
}

 # Private Route Table Association
resource "aws_route_table_association" "mngmt_private" {
  count = "${length(var.private_subnets_mngmt)}"
  subnet_id      = "${element(aws_subnet.mngmt_private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.mngmt_privatert.*.id, count.index)}"
}



# the resource to create Prod VPC

resource "aws_vpc" "prod_vpc" {
  cidr_block  = "${var.prod_workload_vpc_cidr}"
  instance_tenancy = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support = "${var.enable_dns_support}"
  tags = "${merge(var.tags, map("Name", format("%s-prod-vpc", var.name)))}"

}

# the resource to create public subnets in Prod VPC

 resource "aws_subnet" "prod_public_subnet" {
  count = "${length(var.public_subnets_prod)}"
  vpc_id   = "${aws_vpc.prod_vpc.id}"
  cidr_block = "${var.public_subnets_prod[count.index]}"
  map_public_ip_on_launch = true
  tags = "${merge(var.tags, var.public_subnet_tags, map("Name", format("Prod-subnet-public-%s", element(var.public_subnets_prod, count.index))))}"

}

# the resource to create private subnets in Prod VPC

 resource "aws_subnet" "prod_private_subnet" {
  count = "${length(var.private_subnets_prod)}"
  vpc_id   = "${aws_vpc.prod_vpc.id}"
  cidr_block = "${var.private_subnets_prod[count.index]}"
  tags = "${merge(var.tags, var.private_subnet_tags, map("Name", format("Prod-subnet-private-%s", element(var.private_subnets_prod, count.index))))}"
}

# the resource to create an internet gateway for Prod VPC

resource "aws_internet_gateway" "prod_igw" {
  #count = "${length(var.public_subnets_prod) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.prod_vpc.id}"
  tags = "${merge(var.tags, map("Name", format("%s-prod-igw", var.name)))}"
}

# the resource to create the public route table in Prod VPC

resource "aws_route_table" "prod_publicrt" {
  #count = "${length(var.public_subnets_prod) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.prod_vpc.id}"
  tags = "${merge(var.tags, map("Name", format("%s-prod-routetable-public", var.name)))}"
}

# the resource to create the private route table in Prod VPC

resource "aws_route_table" "prod_privatert" {
  #count = "${length(var.private_subnets_prod) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.prod_vpc.id}"
  tags = "${merge(var.tags, map("Name", format("%s-prod-routetable-private", var.name)))}"
}

# Adding routes to the public route table

resource "aws_route" "prod_public_routes" {
  #count = "${length(var.public_subnets_prod) > 0 ? 1 : 0}"
  route_table_id         = "${aws_route_table.prod_publicrt.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.prod_igw.id}"
}

# Public Route Table Association

resource "aws_route_table_association" "prod_public" {
  count = "${length(var.public_subnets_prod)}"
  subnet_id      = "${element(aws_subnet.prod_public_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.prod_publicrt.*.id, count.index)}"
}

 # Private Route Table Association
resource "aws_route_table_association" "prod_private" {
  count = "${length(var.private_subnets_prod)}"
  subnet_id      = "${element(aws_subnet.prod_private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.prod_privatert.*.id, count.index)}"
}



# the resource to create Non Prod VPC

resource "aws_vpc" "non-prod_vpc" {
  cidr_block  = "${var.non-prod_workload_vpc_cidr}"
  instance_tenancy = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support = "${var.enable_dns_support}"
  tags = "${merge(var.tags, map("Name", format("%s-nonprod-vpc", var.name)))}"

}

# the resource to create public subnets in Non Prod VPC

 resource "aws_subnet" "non-prod_public_subnet" { 
  count = "${length(var.public_subnets_non-prod)}"
  vpc_id   = "${aws_vpc.non-prod_vpc.id}"
  map_public_ip_on_launch = true
  cidr_block = "${var.public_subnets_non-prod[count.index]}"
  tags = "${merge(var.tags, var.public_subnet_tags, map("Name", format("NonProd-subnet-public-%s", element(var.public_subnets_non-prod, count.index))))}"

}

# the resource to create private subnets in Non Prod VPC

 resource "aws_subnet" "non-prod_private_subnet" {
  count = "${length(var.private_subnets_non-prod)}"
  vpc_id   = "${aws_vpc.non-prod_vpc.id}"
  cidr_block = "${var.private_subnets_non-prod[count.index]}"
  tags = "${merge(var.tags, var.private_subnet_tags, map("Name", format("NonProd-subnet-private-%s", element(var.private_subnets_non-prod, count.index))))}"
}

# the resource to create an internet gateway for Non Prod VPC

resource "aws_internet_gateway" "non-prod_igw" {
  #count = "${length(var.public_subnets_non-prod) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.non-prod_vpc.id}"
  tags = "${merge(var.tags, map("Name", format("%s-nonprod-igw", var.name)))}"
}

# the resource to create the public route table in Non Prod VPC

resource "aws_route_table" "non-prod_publicrt" {
  #count = "${length(var.public_subnets_non-prod) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.non-prod_vpc.id}"
  tags = "${merge(var.tags, map("Name", format("%s-nonprod-routetable-public", var.name)))}"
}

# the resource to create the private route table in Non Prod VPC

resource "aws_route_table" "non-prod_privatert" {
  #count = "${length(var.private_subnets_non-prod) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.non-prod_vpc.id}"
  tags = "${merge(var.tags, map("Name", format("%s-nonprod-routetable-private", var.name)))}"
}

# Adding routes to the public route table

resource "aws_route" "non-prod_public_routes" {
  #count = "${length(var.public_subnets_non-prod) > 0 ? 1 : 0}"
  route_table_id         = "${aws_route_table.non-prod_publicrt.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.non-prod_igw.id}"
}

# Public Route Table Association

resource "aws_route_table_association" "non-prod_public" {
  count = "${length(var.public_subnets_non-prod)}"
  subnet_id      = "${element(aws_subnet.non-prod_public_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.non-prod_publicrt.*.id, count.index)}"
}

 # Private Route Table Association
resource "aws_route_table_association" "non-prod_private" {
  count = "${length(var.private_subnets_non-prod)}"
  subnet_id      = "${element(aws_subnet.non-prod_private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.non-prod_privatert.*.id, count.index)}"
}

#  Peering Management VPC and Prod VPC


resource "aws_vpc_peering_connection" "Management-Prod"
{
peer_vpc_id = "${aws_vpc.prod_vpc.id}"
vpc_id = "${aws_vpc.mgmt_vpc.id}"
auto_accept = true
tags="${merge(var.tags, map("Name", format("%s-management-prod vpc_peering", var.name)))}"
}

# Peering Management VPC and NonProd VPC

resource "aws_vpc_peering_connection" "Management-Non-Prod"
{
peer_vpc_id = "${aws_vpc.non-prod_vpc.id}"
vpc_id = "${aws_vpc.mgmt_vpc.id}"
auto_accept = true
tags="${merge(var.tags, map("Name", format("%s-management-nonprod vpc_peering", var.name)))}"
}


resource "aws_route" "mngmt2prod" {
  route_table_id = "${aws_route_table.mngmt_privatert.id}"
  destination_cidr_block = "${aws_vpc.prod_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.Management-Prod.id}"
}

resource "aws_route" "mngmt2nonprod" {
  route_table_id = "${aws_route_table.mngmt_privatert.id}"
  destination_cidr_block = "${aws_vpc.non-prod_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.Management-Non-Prod.id}"
}

resource "aws_route" "prod2mngmt" {
  route_table_id = "${aws_route_table.prod_privatert.id}"
  destination_cidr_block = "${aws_vpc.mgmt_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.Management-Prod.id}"
}

resource "aws_route" "nonprod2mngmt" {
  route_table_id = "${aws_route_table.non-prod_privatert.id}"
  destination_cidr_block = "${aws_vpc.mgmt_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.Management-Non-Prod.id}"
}
*/
