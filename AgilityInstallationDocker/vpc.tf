/* variable "access_key1" { 
  description = "AWS access key"
  default = "AKIAJI4INTOM6BXDWR3A"
}

variable "secret_key1" { 
  description = "AWS secret access key"
  default = "WfUf+j2fPB9VGg1qsWJxSMS0FUxnQrW+tSurofSC"
}

variable "region1"     { 
  description = "AWS region to host your network"
  default = "ap-northeast-2"
}

provider "aws" {
access_key = "${var.access_key1}"
secret_key = "${var.secret_key1}"
region = "${var.region1}"
}

resource "aws_instance" "masternode" {
  ami = "ami-a01dc6ce"
  instance_type = "t2.small"
  tags = { 
    Name = "output testing"
  }


connection {
    host = "${self.public_ip}"
    type     = "ssh"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }
  
  provisioner "remote-exec" {
    inline = [
  "sudo mkdir /home/ec2-user/abhi"
  ]
  }
}

output "publicip" {
  value = "${aws_instance.masternode.public_ip}"
}

output "privateip" {
  value = "${aws_instance.masternode.private_ip}"
}

output "publicdns" {
  value = "${aws_instance.masternode.public_dns}"
}
*/
