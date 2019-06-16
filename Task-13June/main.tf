provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "aws_network_interface" "HANAMasterInterface" {
subnet_id       = "${var.primarysubnet}"
security_groups = ["${var.ascssecuritygroup}"]
description = "Network Interface for HANA Master"
source_dest_check = "true"
tags = {
  "SAPASCSABAPInterface" = join("",["SAPASCSABAPInterface-",var.sapsystemid])
  "Interface-Eth0" = "${var.sapsystemid}"
}
}

resource "aws_instance" "web" {
  ami  = "${var.awsamiregionmap["${var.os}"]["${var.region}"]}"
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld"
  }
}
