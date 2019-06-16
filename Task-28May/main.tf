provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "trail" {
  depends_on = ["aws_s3_bucket_policy.bucketpolicy"]
  name = "${var.cloudtrailname}"
  count = "${var.enablelogging == "yes" ? 1 : 0}"
  include_global_service_events = false
  s3_bucket_name = "${var.cloudtrailS3bucket}"
  enable_logging = true
  sns_topic_name = "${var.snstopicname}"
  }


resource "aws_s3_bucket_policy" "bucketpolicy"  {
  bucket = "${var.cloudtrailS3bucket}"
  count = "${var.enablelogging == "yes" ? 1 : 0}"
  policy = <<POLICY
{
  	"Version": "2012-10-17",
  	"Statement": [{
  			"Sid": "AWSCloudTrailAclCheck20150319",
  			"Effect": "Allow",
  			"Principal": {
  				"Service": "cloudtrail.amazonaws.com"
  			},
  			"Action": "s3:GetBucketAcl",
  			"Resource": [
  				"arn:aws:s3:::${var.cloudtrailS3bucket}"
  			]
  		},
      {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": { "Service": "cloudtrail.amazonaws.com" },
            "Action": "s3:PutObject",
            "Resource": ["arn:aws:s3:::${var.cloudtrailS3bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"],
            "Condition": { "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control" } }
        },
        {
            "Sid": "AWSConfigBucketPermissionsCheck",
            "Effect": "Allow",
            "Principal": { "Service": [ "config.amazonaws.com" ] },
            "Action": "s3:GetBucketAcl",
            "Resource":  ["arn:aws:s3:::${var.cloudtrailS3bucket}"]
        },
        {
            "Sid": " AWSConfigBucketDelivery",
            "Effect": "Allow",
            "Principal": { "Service": [ "config.amazonaws.com"] },
            "Action": "s3:PutObject",
            "Resource": ["arn:aws:s3:::${var.cloudtrailS3bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"],
            "Condition": { "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control"}}
        }
      ]
  }
POLICY
}

resource "aws_iam_role" "awsconfigrole" {
  name = "awsconfigiamrole"
  count = "${var.enablelogging == "yes" ? 1 : 0}"
  path = "/"
  assume_role_policy = <<EOF
{
  "Statement": [
            {
              "Effect": "Allow",
              "Principal": { "Service": [ "config.amazonaws.com" ] },
              "Action": [ "sts:AssumeRole" ]
             }
          ]
  }
EOF
}

resource "aws_iam_role_policy_attachment" "iam_policy_attach" {
  count = "${var.enablelogging == "yes" ? 1 : 0}"
  role = "${aws_iam_role.awsconfigrole[count.index].name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_config_configuration_recorder" "configrecorder" {
  count = "${var.enablelogging == "yes" ? 1 : 0}"
  name     = "HANAQuickStart-ConfigRecord"
  role_arn = "${aws_iam_role.awsconfigrole[count.index].arn}"
  recording_group {
     all_supported = "false"
     include_global_resource_types = "false"
     resource_types = ["AWS::EC2::Instance", "AWS::CloudTrail::Trail","AWS::EC2::NetworkAcl","AWS::EC2::RouteTable","AWS::EC2::Subnet","AWS::EC2::VPC","AWS::EC2::Volume","AWS::EC2::NetworkInterface","AWS::EC2::SecurityGroup","AWS::EC2::Instance"]
  }
}

resource "aws_config_delivery_channel" "configdeliverychannel" {
  count = "${var.enablelogging == "yes" ? 1 : 0}"
  depends_on     = ["aws_config_configuration_recorder.configrecorder"]
  name           = "AWSConfigDeliveryChannel"
  s3_bucket_name = "${var.cloudtrailS3bucket}"
  snapshot_delivery_properties {
     delivery_frequency = "One_Hour"
  }
}

resource "aws_sqs_queue" "deploymentinterruptq" {
  delay_seconds = 0
  visibility_timeout_seconds = 0
}

resource "aws_security_group" "hanasg" {
  name        = "HANASecurityGroup"
  description = "Enable external access to the HANA Master and allow communication from slave instances"
  vpc_id      = "${var.VPCID}"

  ingress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.PrivSubCIDR}"]
  }
  ingress {
    from_port   = 111
    to_port     = 111
    protocol    = "udp"
    cidr_blocks = ["${var.PrivSubCIDR}"]
  }
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "udp"
    cidr_blocks =["${var.PrivSubCIDR}"]
  }
  ingress {
    from_port   = 4000
    to_port     = 4002
    protocol    = "udp"
    cidr_blocks =["${var.PrivSubCIDR}"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks =["${var.PrivSubCIDR}"]
  }
  ingress {
    from_port   = join("", ["5", "${var.SAPInstanceNum}", "13"])
    to_port     = join("", ["5", "${var.SAPInstanceNum}", "14"])
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = join("", ["3", "${var.SAPInstanceNum}", "13"])
    to_port     = join("", ["3", "${var.SAPInstanceNum}", "13"])
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = join("", ["3", "${var.SAPInstanceNum}", "15"])
    to_port     = join("", ["3", "${var.SAPInstanceNum}", "15"])
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = join("", ["3", "${var.SAPInstanceNum}", "17"])
    to_port     = join("", ["3", "${var.SAPInstanceNum}", "17"])
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = join("", ["3", "${var.SAPInstanceNum}", "41"])
    to_port     = join("", ["3", "${var.SAPInstanceNum}", "44"])
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = join("", ["80", "${var.SAPInstanceNum}", ""])
    to_port     = join("", ["80", "${var.SAPInstanceNum}", ""])
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = join("", ["3", "${var.SAPInstanceNum}", "09"])
    to_port     = join("", ["3", "${var.SAPInstanceNum}", "09"])
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = join("", ["43", "${var.SAPInstanceNum}", ""])
    to_port     = join("", ["43", "${var.SAPInstanceNum}", ""])
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = 1128
    to_port     = 1128
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = 1129
    to_port     = 1129
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks =["${var.DMZCIDR}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =["0.0.0.0/0"]
  }
  }

  resource "aws_security_group_rule" "hanasgupdate" {
  count = "${var.ApplicationCIDR != "0.0.0.0/0" ? 1 : 0}"
  description = "SAP Client Traffic"
  type = "ingress"
  from_port   = join("", ["3", "${var.SAPInstanceNum}", "13"])
  to_port     = join("", ["3", "${var.SAPInstanceNum}", "17"])
  protocol    = "tcp"
  cidr_blocks =["${var.ApplicationCIDR}"]
  security_group_id = "${aws_security_group.hanasg.id}"
  }




  resource "aws_security_group"  "hanaslavesg" {
  count = "${var.hostcount == 2 || var.hostcount == 3 || var.hostcount == 4 || var.hostcount == 5 || var.hostcount == 6 ? 1 : 0}"
  description = "Enable communication between the master and slave instances"
  vpc_id = "${var.VPCID}"
  ingress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.PrivSubCIDR}"]
  }
  ingress {
    from_port   = join("", ["5", "${var.SAPInstanceNum}", "13"])
    to_port     = join("", ["5", "${var.SAPInstanceNum}", "14"])
    protocol    = "tcp"
    cidr_blocks = ["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = join("", ["3", "${var.SAPInstanceNum}", "15"])
    to_port     = join("", ["3", "${var.SAPInstanceNum}", "15"])
    protocol    = "tcp"
    cidr_blocks = ["${var.DMZCIDR}"]
  }
  ingress {
    from_port   = join("", ["3", "${var.SAPInstanceNum}", "17"])
    to_port     = join("", ["3", "${var.SAPInstanceNum}", "17"])
    protocol    = "tcp"
    cidr_blocks = ["${var.DMZCIDR}"]
  }
  ingress {
    from_port   =  1128
    to_port     =  1129
    protocol    = "tcp"
    cidr_blocks = ["${var.DMZCIDR}"]
  }
  ingress {
    from_port   =  8080
    to_port     =  8080
    protocol    = "tcp"
    cidr_blocks = ["${var.DMZCIDR}"]
  }
  ingress {
    from_port   =  8443
    to_port     =  8443
    protocol    = "tcp"
    cidr_blocks = ["${var.DMZCIDR}"]
  }
  ingress {
    from_port   =  22
    to_port     =  22
    protocol    = "tcp"
    cidr_blocks = ["${var.DMZCIDR}"]
  }
  egress {
    from_port   =  0
    to_port     =  0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  }

  resource "aws_network_interface" "HANAMasterInterface" {
  subnet_id       = "${var.HANASubnet}"
  security_groups = ["${aws_security_group.hanasg.id}"]
  description = "Network Interface for HANA Master"
  source_dest_check = "true"
  tags = {
    "Network" = "Private"
  }
}

resource "aws_network_interface" "HANAWorker1Interface" {
count = "${var.hostcount == 2 || var.hostcount == 3 || var.hostcount == 4 || var.hostcount == 5 || var.hostcount == 6 ? 1 : 0}"
subnet_id       = "${var.HANASubnet}"
description = "Interface for HANA Worker 1"
security_groups = ["${aws_security_group.hanaslavesg[count.index].id}"]
source_dest_check = "true"
tags = {
  "Network" = "Private"
}
}

resource "aws_network_interface" "HANAWorker2Interface" {
count = "${var.hostcount == 3 || var.hostcount == 4 || var.hostcount == 5 || var.hostcount == 6 ? 1 : 0}"
subnet_id       = "${var.HANASubnet}"
description = "Interface for HANA Worker 2"
security_groups = ["${aws_security_group.hanaslavesg[count.index].id}"]
source_dest_check = "true"
tags = {
  "Network" = "Private"
}
}

resource "aws_network_interface" "HANAWorker3Interface" {
count = "${var.hostcount == 4 || var.hostcount == 5 || var.hostcount == 6 ? 1 : 0}"
subnet_id       = "${var.HANASubnet}"
description = "Interface for HANA Worker 3"
security_groups = ["${aws_security_group.hanaslavesg[count.index].id}"]
source_dest_check = "true"
tags = {
  "Network" = "Private"
}
}

resource "aws_network_interface" "HANAWorker4Interface" {
count = "${var.hostcount == 5 || var.hostcount == 6 ? 1 : 0}"
subnet_id       = "${var.HANASubnet}"
description = "Interface for HANA Worker 4"
security_groups = ["${aws_security_group.hanaslavesg[count.index].id}"]
source_dest_check = "true"
tags = {
  "Network" = "Private"
}
}

resource "aws_network_interface" "HANAWorker5Interface" {
count = "${var.hostcount == 6 ? 1 : 0}"
subnet_id       = "${var.HANASubnet}"
description = "Interface for HANA Worker 5"
security_groups = ["${aws_security_group.hanaslavesg[count.index].id}"]
source_dest_check = "true"
tags = {
  "Network" = "Private"
}
}

resource "aws_iam_role" "hanaiamrole" {
  name = "HANAIAMRole"
  path = "/"
  assume_role_policy = <<EOF
{
  "Statement": [
            {
              "Effect": "Allow",
              "Principal": { "Service": [ "ec2.amazonaws.com", "ssm.amazonaws.com"] },
              "Action": [ "sts:AssumeRole" ]
             }
          ]
  }
EOF
}

resource "aws_iam_role_policy_attachment" "iam_policy_attach01" {
  role = "${aws_iam_role.hanaiamrole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "hanaiamrole_profile" {
  name = "HANAIAMProfile"
  role = "${aws_iam_role.hanaiamrole.name}"
  path = "/"
}

resource "aws_iam_role" "rdpinstancerootrole" {
 count = "${var.InstallRDPInstance == "yes" ? 1 : 0}"
 name = "RDPInstanceRootRole"
 path = "/"
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
 "Statement": [
           {
             "Effect": "Allow",
             "Principal": { "Service": [ "ec2.amazonaws.com"] },
             "Action": [ "sts:AssumeRole" ]
            }
         ]
 }
EOF
}

resource "aws_iam_role_policy" "rdpinstancerolepolicy" {
 count = "${var.InstallRDPInstance == "yes" ? 1 : 0}"
 name = "root"
 role = "${aws_iam_role.rdpinstancerootrole[count.index].id}"
 policy = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [
         {
             "Effect": "Allow",
             "Action": [
                 "s3:*",
                 "ec2:Describe*",
                 "ec2:AttachNetworkInterface",
                 "ec2:AttachVolume",
                 "ec2:CreateTags",
                 "ec2:CreateVolume",
                 "ec2:DeleteVolume",
                 "ec2:RunInstances",
                 "ec2:StartInstances",
                 "ec2:CreateSecurityGroup",
                 "ec2:CreatePlacementGroup",
                 "ec2:CreateSnapshot"
             ],
             "Resource": "*"
         },
         {
             "Action": [
                 "sqs:*"
             ],
             "Effect": "Allow",
             "Resource": "*"
         },
         {
             "Effect": "Allow",
             "Action": [
                 "cloudformation:CreateStack",
                 "cloudformation:DeleteStack",
                 "cloudformation:DescribeStack",
                 "cloudformation:EstimateTemplateCost",
                 "cloudformation:ValidateTemplate",
                 "cloudformation:DescribeStackEvents",
                 "cloudformation:DescribeStackResource",
                 "cloudformation:DescribeStackResources",
                 "cloudformation:DescribeStacks"
             ],
             "Resource": [
                 "*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "iam:CreateRole"
             ],
             "Resource": [
                 "*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "iam:PutRolePolicy"
             ],
             "Resource": [
                 "*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "iam:CreateInstanceProfile"
             ],
             "Resource": [
                 "*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "iam:AddRoleToInstanceProfile"
             ],
             "Resource": [
                 "*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "iam:PassRole"
             ],
             "Resource": [
                 "*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "ec2:RevokeSecurityGroupEgress"
             ],
             "Resource": [
                 "*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "ec2:AuthorizeSecurityGroupEgress"
             ],
             "Resource": [
                 "*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "ec2:AuthorizeSecurityGroupIngress"
             ],
             "Resource": [
                 "*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "ec2:CreateNetworkInterface"
             ],
             "Resource": [
                 "*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "ec2:ModifyNetworkInterfaceAttribute"
             ],
             "Resource": [
                 "*"
             ]
         }
     ]
 }
 EOF
}

resource "aws_iam_instance_profile" "rdpinstancerootroleprofile" {
  count = "${var.InstallRDPInstance == "yes" ? 1 : 0}"
  name = "RDPProfile"
  role = "${aws_iam_role.rdpinstancerootrole.name}"
  path = "/"
}

resource "aws_eip" "rdpeip" {
  vpc      = true
}

resource "aws_eip_association" "eip_assoc" {
  count = "${var.InstallRDPInstance == "yes" ? 1 : 0}"
  allocation_id = "${aws_eip.rdpeip.id}"
  network_interface_id = "${aws_network_interface.rdpinterface[count.index].id}"
}

resource "aws_network_interface" "rdpinterface" {
count = "${var.InstallRDPInstance == "yes" ? 1 : 0}"
subnet_id       = "${var.DMZSubnet}"
description = "Interface for RDP Instance"
security_groups = ["${aws_security_group.rdpsg.id}"]
source_dest_check = "true"
tags = {
  "Network" = "Public"
}
}

resource "aws_security_group" "rdpsg" {
 description = "RDP Instance security group"
 vpc_id = "${var.VPCID}"
 ingress {
   from_port   = 3389
   to_port     = 3389
   protocol    = "tcp"
   cidr_blocks = ["${var.RemoteAccessCIDR}"]
 }
 egress {
   from_port   = 1
   to_port     = 65535
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_placement_group" "web" {
  name = "hana-placementgroup"
  strategy = "cluster"
}

resource "aws_instance" "web" {
  ami           = "${var.windows2012ami}"
  instance_type = "${var.rdpinstancetype}"
  key_name = "${var.keyname}"
  network_interface {
  network_interface_id = "${aws_network_interface.rdpinterface.id}"
  device_index = 0
  }
  iam_instance_profile = "${aws_iam_instance_profile.rdpinstancerootroleprofile.id}"
  tags = {
    Name = "SAP RDP Instance"
  }
  user_data = <<-EOF
  <powershell>
  Set-ExecutionPolicy RemoteSigned -Force
  Start-Process -FilePath msiexec -ArgumentList /i,  "http://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi", /passive -wait
  </powershell>
  EOF
}
