resource "aws_security_group" "swarm_sg" {
  name = "swarm-security-group"
  description = "Security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id = "${aws_vpc.mgmt_vpc.id}"
  ingress {
    from_port   = "2377"
    to_port     = "2377"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "7946"
    to_port     = "7946"
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "2376"
    to_port   = "2376"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "8443"
    to_port   = "8443"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "7946"
    to_port   = "7946"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
   ingress {
    from_port = "80"
    to_port   = "80"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    
   ingress {
    from_port = "8080"
    to_port   = "8080"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    
   ingress {
    from_port = "3389"
    to_port   = "3389"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    
   ingress {
    from_port = "5985"
    to_port   = "5985"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    
   ingress {
    from_port = "5986"
    to_port   = "5986"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    
  ingress {
    from_port = "4789"
    to_port   = "4789"
    protocol  = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "443"
    to_port   = "443"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "8022"
    to_port   = "8022"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "8022"
    to_port   = "8022"
    protocol  = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  tags { 
    Name = "SwarmClusterSG" 
  }
}


resource "aws_instance" "masternode" {
  ami = "ami-a01dc6ce"
  instance_type = "m4.xlarge"
  security_groups = ["${aws_security_group.swarm_sg.id}"]
  #vpc_security_group_ids = ["sg-c05f4ba8"]
  subnet_id = "${aws_subnet.mngmt_public_subnet.id}"
  connection {
    host = "${self.public_ip}"
    type     = "ssh"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }

  provisioner "remote-exec" {
    inline = [
    "echo 'CHANGING HOSTNAME'",
    "echo ${var.masternode} > /home/smadmin/masternode",
      "echo 'The actual hostname is...'",
      "hostname",
      "hostnamectl",
      "echo 'Changing the hostname....'",
      "sudo hostnamectl set-hostname $(cat /home/smadmin/masternode)",
      "echo 'Rebooting the machine....'",
      "echo 'The changed hostname......'",
      "hostname",
  "docker network create --subnet=10.10.0.0/16 --gateway 10.10.0.1 -o com.docker.network.bridge.enable_icc=false -o com.docker.network.bridge.name=docker_gwbridge -o com.docker.network.bridge.enable_ip_masquerade=true docker_gwbridge",
  "sudo firewall-cmd --permanent --zone=trusted --change-interface=docker_gwbridge",
  "sudo firewall-cmd --zone=public --permanent --add-masquerade",
  "sudo firewall-cmd --zone=public --permanent --add-port=2377/tcp",
  "sudo firewall-cmd --zone=public --permanent --add-port=2376/tcp",
  "sudo firewall-cmd --zone=public --permanent --add-port=7946/tcp",
  "sudo firewall-cmd --zone=public --permanent --add-port=7946/udp",
  "sudo firewall-cmd --zone=public --permanent --add-port=4789/udp",
  "sudo firewall-cmd --zone=trusted --permanent --add-masquerade",
  "sudo firewall-cmd --zone=trusted --permanent --add-port=2377/tcp",
  "sudo firewall-cmd --zone=trusted --permanent --add-port=2376/tcp",
  "sudo firewall-cmd --zone=trusted --permanent --add-port=7946/tcp",
  "sudo firewall-cmd --zone=trusted --permanent --add-port=7946/udp",
  "sudo firewall-cmd --zone=trusted --permanent --add-port=4789/udp",
  "sudo firewall-cmd --reload",
  "sudo systemctl stop docker",
  "sudo systemctl start docker",
  "sudo curl -k -u servicemesh:SMFY@cce55 'https://ftp-aus.servicemesh.com/csc/solutions/11.0/agility-images-11.0.0.tar.gz' -o /home/smadmin/agility-images-11.0.0.tar.gz",
  "docker swarm init",
  "docker swarm join-token manager",
  "sudo docker swarm join-token --quiet manager > /home/smadmin/token",
  "docker image load -i agility-images-11.0.0.tar.gz",
  "docker images"
    ]
  }
  tags = { 
    Name = "swarm-master"
  }
}