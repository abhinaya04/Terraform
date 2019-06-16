resource "aws_instance" "workernode2" {
  depends_on = ["aws_instance.workernode1"],
  ami = "ami-a01dc6ce"
  instance_type = "m4.xlarge"
  security_groups = ["${aws_security_group.swarm_sg.id}"]
  subnet_id = "${aws_subnet.mngmt_public_subnet.id}"
  #vpc_security_group_ids = ["sg-c05f4ba8"]
  connection {
    host = "${self.public_ip}"
    type     = "ssh"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }
  provisioner "remote-exec" {
    inline = [
    "echo 'CHANGING HOSTNAME'",
    "echo ${var.workernode2} > /home/smadmin/workernode2",
      "echo 'The actual hostname is...'",
      "hostname",
      "hostnamectl",
      "echo 'Changing the hostname....'",
      "sudo hostnamectl set-hostname $(cat /home/smadmin/workernode2)",
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
  "sudo yum install sshpass -y",
  "sudo sshpass -p 'M3sh@dmin!' scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null smadmin@${aws_instance.masternode.private_ip}:/home/smadmin/token /home/smadmin/",
  
  "sudo sshpass -p 'M3sh@dmin!' scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null smadmin@${aws_instance.masternode.private_ip}:/home/smadmin/agility-images-11.0.0.tar.gz /home/smadmin/",
  
  "sudo curl -k -u servicemesh:SMFY@cce55 'https://ftp-aus.servicemesh.com/csc/solutions/11.0/agility-cli-11.0.0.tar.gz' -o /home/smadmin/agility-cli-11.0.0.tar.gz",
  "sudo docker swarm join --token $(cat /home/smadmin/token) ${aws_instance.masternode.private_ip}:2377",
  "docker image load -i agility-images-11.0.0.tar.gz",
  "docker images",
  "docker node ls",
  "sudo tar -xvzf /home/smadmin/agility-cli-11.0.0.tar.gz",
  "sudo /home/smadmin/swarm-scale 3",
  "sudo /home/smadmin/swarm-start"
    ]
  }
  tags = { 
    Name = "swarm-worker-2"
  }
}
