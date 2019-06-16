provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "master" {
  instance_type          = "t2.micro"
  ami                    = "ami-06bcd1131b2f55803"
  key_name               = "${var.keyname}"
  user_data = "${data.template_file.user_data.rendered}"
}

data "template_file" "user_data" {
  template = "${file("templates/user_data.tpl")}"
}