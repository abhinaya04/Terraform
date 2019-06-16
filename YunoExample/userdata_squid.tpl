#!/bin/bash
echo ${host_eni} > /var/tmp/eni-id.txt #load my my_eni_id here
sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum --enablerepo=epel install ansible -y
sudo yum install awscli -y
sudo yum install git -y
my_instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
my_eni_id=$(cat /var/tmp/eni-id.txt)
export AWS_DEFAULT_REGION="us-east-1"
/usr/bin/aws ec2 attach-network-interface --network-interface-id $my_eni_id --instance-id $my_instance_id --device-index 1
echo 1 | sudo tee --append /proc/sys/net/ipv4/ip_forward
sudo rm -rf /var/tmp/squid
sudo tar -C /var/tmp/ -xvf /var/tmp/squid.tar.bz2
#git clone https://imkarthikn:'karthiS%40123'@bitbucket.org/gc-engineering/release_management.git /var/tmp/squid -b drafty_squid
sudo /bin/ansible-playbook /var/tmp/squid/ansible_playbooks/common_controller.yml --extra-vars "role_name=squid job=restart product=drafty compliance=nonpci squid_version=squid-3.5.20-12.el7"
sudo cp -f /var/tmp/squid/ansible_playbooks/roles/squid/files/squid.sh /root/squid.sh
sudo chmod +x /root/squid.sh
sudo /bin/bash /root/squid.sh
sudo echo "/bin/bash /root/squid.sh" >> /etc/rc.local
sudo /bin/ansible-playbook /var/tmp/squid/ansible_playbooks/common_controller.yml --extra-vars "role_name=squid job=restart product=drafty compliance=nonpci squid_version=squid-3.5.20-12.el7"
#sudo echo "git clone https://imkarthikn:'karthiS%40123'@bitbucket.org/gc-engineering/release_management.git /var/tmp/squid -b drafty_squid" >> /etc/rc.local
sudo echo 'sudo /bin/ansible-playbook /var/tmp/squid/ansible_playbooks/common_controller.yml --extra-vars "role_name=squid job=restart product=drafty compliance=nonpci squid_version=squid-3.5.20-12.el7"' >> /etc/rc.local
sudo chmod +x /etc/rc.d/rc.local
sudo rm -rf /var/lib/cloud/instances/*/sem/config_scripts_user #this changes will make the heartbeat script to run on every reboot
sudo chown devopsuser /var/tmp/squid/scripts/shell/drafty/squid_heartbeat.sh #this will change user has devopsuser
sudo -u devopsuser sh /var/tmp/squid/scripts/shell/drafty/squid_heartbeat.sh ${failover_eni} "${change_rt}" ${failover_ip} ${host_eni} >> /tmp/squid_heartbeat.out & #This is the squid heartbeat health check script.