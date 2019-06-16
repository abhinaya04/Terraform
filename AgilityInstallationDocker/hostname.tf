


resource "aws_instance" "masternode" {
  ami = "ami-a01dc6ce"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-c05f4ba8"]
  subnet_id = "subnet-3485a57e"
  connection {
    host = "${self.public_ip}"
    type     = "ssh"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }
  provisioner "remote-exec" {
    inline = [
      "echo ${var.hostname} > /home/smadmin/hostname",
      "echo 'The actual hostname is...'",
      "hostname",
      "hostnamectl",
      "echo 'Changing the hostname....'",
      "sudo hostnamectl set-hostname $(cat /home/smadmin/hostname)",
      "echo 'Rebooting the machine....'",
      "echo 'The changed hostname......'",
      "hostname"
    ]
    }

    tags = { 
    Name = "abhihostnametest01"
  }
}
