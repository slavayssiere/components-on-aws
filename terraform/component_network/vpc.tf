resource "aws_vpc" "pf_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = "${
    map(
      "Name", "demo-vpc-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_internet_gateway" "pf_vpc_igtw" {
  vpc_id = "${aws_vpc.pf_vpc.id}"
}

/*
  Public Subnet
*/
resource "aws_subnet" "demo_sn_public_a" {
  vpc_id = "${aws_vpc.pf_vpc.id}"

  cidr_block        = "${var.public_subnet_a_cidr}"
  availability_zone = "${var.region}a"

  tags = "${
    map(
      "Name", "demo_sn_public_a-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_subnet" "demo_sn_public_b" {
  vpc_id = "${aws_vpc.pf_vpc.id}"

  cidr_block        = "${var.public_subnet_b_cidr}"
  availability_zone = "${var.region}b"

  tags = "${
    map(
      "Name", "demo_sn_public_b-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_subnet" "demo_sn_public_c" {
  vpc_id = "${aws_vpc.pf_vpc.id}"

  cidr_block        = "${var.public_subnet_c_cidr}"
  availability_zone = "${var.region}c"

  tags = "${
    map(
      "Name", "demo_sn_public_c-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

/*
  Private Subnet
*/
resource "aws_subnet" "demo_sn_private_a" {
  vpc_id = "${aws_vpc.pf_vpc.id}"

  cidr_block        = "${var.private_subnet_a_cidr}"
  availability_zone = "${var.region}a"

  tags = "${
    map(
      "Name", "demo_sn_private_a-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_subnet" "demo_sn_private_b" {
  vpc_id = "${aws_vpc.pf_vpc.id}"

  cidr_block        = "${var.private_subnet_b_cidr}"
  availability_zone = "${var.region}b"

  tags = "${
    map(
      "Name", "demo_sn_private_b-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_subnet" "demo_sn_private_c" {
  vpc_id = "${aws_vpc.pf_vpc.id}"

  cidr_block        = "${var.private_subnet_c_cidr}"
  availability_zone = "${var.region}c"

  tags = "${
    map(
      "Name", "demo_sn_private_c-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

/* add route to public subnet */

/* ici on autorise le réseau "public" à accéder à la Gateway internet */

resource "aws_route_table" "pf_vpc_rt_public" {
  vpc_id = "${aws_vpc.pf_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.pf_vpc_igtw.id}"
  }

  tags = "${
    map(
      "Name", "pf_vpc_rt_public-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_route_table_association" "pf_vpc_rta_public_a" {
  subnet_id      = "${aws_subnet.demo_sn_public_a.id}"
  route_table_id = "${aws_route_table.pf_vpc_rt_public.id}"
}

resource "aws_route_table_association" "pf_vpc_rta_public_b" {
  subnet_id      = "${aws_subnet.demo_sn_public_b.id}"
  route_table_id = "${aws_route_table.pf_vpc_rt_public.id}"
}

resource "aws_route_table_association" "pf_vpc_rta_public_c" {
  subnet_id      = "${aws_subnet.demo_sn_public_c.id}"
  route_table_id = "${aws_route_table.pf_vpc_rt_public.id}"
}

/* nat gateway eu-west-1a */

resource "aws_eip" "demo_nat_a_gw_eip" {
  count = var.enable_nat_gateway ? 1 : 0
  vpc   = true
}

resource "aws_nat_gateway" "demo_nat_a_gw" {
  count      = var.enable_nat_gateway ? 1 : 0
  depends_on = ["aws_internet_gateway.pf_vpc_igtw"]

  allocation_id = "${aws_eip.demo_nat_a_gw_eip[count.index].id}"
  subnet_id     = "${aws_subnet.demo_sn_public_a.id}"
}

/* nat gateway eu-west-1b */

resource "aws_eip" "demo_nat_b_gw_eip" {
  count = var.enable_nat_gateway ? 1 : 0
  vpc   = true
}

resource "aws_nat_gateway" "demo_nat_b_gw" {
  count      = var.enable_nat_gateway ? 1 : 0
  depends_on = ["aws_internet_gateway.pf_vpc_igtw"]

  allocation_id = "${aws_eip.demo_nat_b_gw_eip[count.index].id}"
  subnet_id     = "${aws_subnet.demo_sn_public_b.id}"
}

/* nat gateway eu-west-1c */

resource "aws_eip" "demo_nat_c_gw_eip" {
  count = var.enable_nat_gateway ? 1 : 0
  vpc   = true
}

resource "aws_nat_gateway" "demo_nat_c_gw" {
  count      = var.enable_nat_gateway ? 1 : 0
  depends_on = ["aws_internet_gateway.pf_vpc_igtw"]

  allocation_id = "${aws_eip.demo_nat_c_gw_eip[count.index].id}"
  subnet_id     = "${aws_subnet.demo_sn_public_c.id}"
}

/* ici on autorise le réseau "privé" à accéder à la NAT Gateway */

resource "aws_route_table" "pf_vpc_rt_a_private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = "${aws_vpc.pf_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.demo_nat_a_gw[count.index].id}"
  }

  tags = "${
    map(
      "Name", "pf_vpc_rt_private_a-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_route_table_association" "pf_vpc_rta_private_a" {
  count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = "${aws_subnet.demo_sn_private_a.id}"
  route_table_id = "${aws_route_table.pf_vpc_rt_a_private[count.index].id}"
}

resource "aws_route_table" "pf_vpc_rt_b_private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = "${aws_vpc.pf_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.demo_nat_b_gw[count.index].id}"
  }

  tags = "${
    map(
      "Name", "pf_vpc_rt_private_b-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_route_table_association" "pf_vpc_rta_private_b" {
  count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = "${aws_subnet.demo_sn_private_b.id}"
  route_table_id = "${aws_route_table.pf_vpc_rt_b_private[count.index].id}"
}

resource "aws_route_table" "pf_vpc_rt_c_private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = "${aws_vpc.pf_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.demo_nat_c_gw[count.index].id}"
  }

  tags = "${
    map(
      "Name", "pf_vpc_rt_private_c-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}

resource "aws_route_table_association" "pf_vpc_rta_private_c" {
  count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = "${aws_subnet.demo_sn_private_c.id}"
  route_table_id = "${aws_route_table.pf_vpc_rt_c_private[count.index].id}"
}
