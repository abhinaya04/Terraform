provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}


resource "aws_instance" "SAPDBInstance" {
    #count = "${var.autorecoverydb ? 1 : 0}"
    ami = "ami-06bcd1131b2f55803"
    key_name = "${var.keyname}"
    #user_data = "${data.template_file.init.rendered}"
    instance_type = "t2.micro"
    #iam_instance_profile = "${var.SAPIAMProfile}"
    ebs_block_device {
     device_name = "/dev/xvda"
     volume_type = "gp2"
     volume_size =  "50"
    }
 #   network_interface {
 #      device_index = 0
 #      network_interface_id = "${var.SAPDBInterface}"
 #  }
    tags = {
         Name = "${var.DBHOSTNAME}"
}
}

resource "aws_instance" "masternode" {
  ami = "ami-06bcd1131b2f55803"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-0cc4387ac60f76166"]
  key_name = "test01"
    connection {
    host = "${self.public_ip}"
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${file("c:/LEARNINGS/AWS/MYKEYPAIRS/test01.pem")}"
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'The actual hostname is...'",
      "mkdir abhinaya",
      "hostname",
      "echo ${aws_instance.masternode.private_ip} >> /home/ec2-user/ipadd.txt",
      "echo ${aws_instance.masternode.private_ip}",
      "echo ${aws_instance.SAPDBInstance.id}",
      "echo ${aws_ebs_volume.usrsapvol.id}"
    ]
    }
    tags = { 
    Name = "abhihostnametest01"
  }
}



resource "aws_cloudwatch_metric_alarm" "AutoRecoverAlarmMaster" {
  alarm_name                = "terraform-test-foobar5"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "Trigger a recovery when instance status check fails for 2 consecutive minutes."
  dimensions = {
    InstanceId = "${aws_instance.SAPDBInstance.id}"
  }
  alarm_actions     = [ "${format("arn:aws:automate:%s:ec2:recover",var.region)}" ]
                      
}

resource "aws_ebs_volume" "usrsapvol" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 60
  tags = "${merge(map("Name", format("usrsapvol-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

  resource "aws_volume_attachment" "MntPointusrsapvol" {
  device_name = "/dev/sdb"
  volume_id   = "${aws_ebs_volume.usrsapvol.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "oraclevol" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 60
  tags = "${merge(map("Name", format("oraclevol-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

   resource "aws_volume_attachment" "MntPointorasapvol" {
  device_name = "/dev/sdj"
  volume_id   = "${aws_ebs_volume.oraclevol.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

#data "template_file" "start" {
#  template = "${file("start.tpl")}"
#}

resource "aws_ebs_volume" "saporadbvol2" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 60
  tags = "${merge(map("Name", format("saporadbvol2-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

   resource "aws_volume_attachment" "MntPointsaporadbvol2" {
  device_name = "/dev/sde"
  volume_id   = "${aws_ebs_volume.saporadbvol2.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "saporadbvol3" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 60
  tags = "${merge(map("Name", format("saporadbvol3-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

     resource "aws_volume_attachment" "MntPointsaporadbvol3" {
  device_name = "/dev/sdf"
  volume_id   = "${aws_ebs_volume.saporadbvol3.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "saporadbvol4" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 60
  tags = "${merge(map("Name", format("saporadbvol4-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

resource "aws_volume_attachment" "MntPointsaporadbvol4" {
  device_name = "/dev/sdg"
  volume_id   = "${aws_ebs_volume.saporadbvol4.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "saporalogvol1" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 60
  tags = "${merge(map("Name", format("saporalogvol1-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

  resource "aws_volume_attachment" "MntPointsaporalogvol1" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.saporalogvol1.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "saporalogvol2" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 60
  tags = "${merge(map("Name", format("saporalogvol2-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

  resource "aws_volume_attachment" "MntPointsaporalogvol2" {
  device_name = "/dev/sdi"
  volume_id   = "${aws_ebs_volume.saporalogvol2.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "sapmirrlogvol1" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 60
  tags = "${merge(map("Name", format("sapmirrlogvol1-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

  resource "aws_volume_attachment" "MntPointsapmirrlogvol1" {
  device_name = "/dev/sds"
  volume_id   = "${aws_ebs_volume.sapmirrlogvol1.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "sapmirrlogvol2" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 60
  tags = "${merge(map("Name", format("sapmirrlogvol2-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

  resource "aws_volume_attachment" "MntPointsapmirrlogvol2" {
  device_name = "/dev/sdt"
  volume_id   = "${aws_ebs_volume.sapmirrlogvol2.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "saporaswapvol" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 21
  tags = "${merge(map("Name", format("saporaswapvol-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

resource "aws_volume_attachment" "MntPointsaporaswapvol" {
  device_name = "/dev/sdk"
  volume_id   = "${aws_ebs_volume.saporaswapvol.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "saporabackupvol" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 8
  tags = "${merge(map("Name", format("saporabackupvol-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

resource "aws_volume_attachment" "MntPointsaporabackupvol" {
  device_name = "/dev/sdn"
  volume_id   = "${aws_ebs_volume.saporabackupvol.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "saporasaptempvol" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 8
  tags = "${merge(map("Name", format("saporasaptempvol-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

resource "aws_volume_attachment" "MntPointsaporasaptempvol" {
  device_name = "/dev/sdp"
  volume_id   = "${aws_ebs_volume.saporasaptempvol.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "customvol" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 8
  tags = "${merge(map("Name", format("customvol-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

resource "aws_volume_attachment" "MntPointsaporacustvol" {
  device_name = "/dev/sdo"
  volume_id   = "${aws_ebs_volume.customvol.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}

resource "aws_ebs_volume" "sapexportvol" {
  availability_zone = "${var.aztodeploy}"
  encrypted  = true
  #kms_key_id = "${var.kmskeyid}"
  type = "gp2"
  size = 8
  tags = "${merge(map("Name", format("sapexportvol-%s", var.sid)), map("VitalizeId", var.vitlaizeid))}"
  }

                     resource "aws_volume_attachment" "MntPointsaporaexportvol" {
  device_name = "/dev/sdq"
  volume_id   = "${aws_ebs_volume.sapexportvol.id}"
  instance_id = "${aws_instance.SAPDBInstance.id}"
}