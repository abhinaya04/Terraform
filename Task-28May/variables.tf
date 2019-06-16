variable "aws_access_key" {
  default= "AKIAI3KBUACQY4BZCGYA"
  type = "string"
  description = "Access key of the AWS Account"
}

variable "aws_secret_key" {
  description = "Secret Access Key of the AWS Account"
  type = "string"
  default     = "2PCGltzoQwUaJrZL8v6G4OywRsjNeWH796+F36l9"
}

variable "region" {
  default= "ap-south-1"
  type = "string"
  description = "AWS Region Name"
}

variable "enablelogging" {
   description = "Enable (Yes) or disable (No) logging with AWS Cloudtrail and AWS Config"
   default = "yes"
   type = "string"
}

variable "cloudtrailS3bucket" {
   description = "Name of S3 bucket where AWS CloudTrail trails and AWS Config log files can be stored (e.g., mycloudtrail)."
   default = "giveaccessbucket"
   type = "string"
}

variable "cloudtrailname" {
default = "mytrail"
type = "string"
}

variable "snstopicname" {
default = ""
type = "string"
}

variable "account_id" {
default = "716845053178"
type = "string"
}


variable "hostcount" {
  default = 6
  description = "The host count"
  type = number
}

variable "s3_bucket_name" {
  type = "string"
  default = "testabhi01"
}

variable "HANASubnet" {
description = "The existing private subnet in your VPC where you want to deploy SAP HANA"
type = "string"
default = "subnet-6124e81a"
}

variable "PrivSubCIDR" {
description = "CIDR block of the private subnet where SAP HANA will be deployed."
type = "string"
default = "10.0.1.0/24"
}

variable "DMZCIDR" {
 description = "CIDR block of the public DMZ subnet where BASTION Host / NAT Gateway exist."
  type = "string"
 default = "10.0.2.0/24"
}

variable "RemoteAccessCIDR" {
description = "CIDR block from where you want to access your RDP instance."
type = "string"
default = "0.0.0.0/0"
}

variable "VPCID"  {
description = "The existing Amazon VPC where you want to deploy SAP HANA."
default = "vpc-0bfaa263"
type = "string"
}

variable "ApplicationCIDR"  {
description = "CIDR block of subnet where SAP Application servers are deployed."
default = "0.0.0.0/0"
type = "string"
}

variable "DMZSubnet"  {
description = "The existing public subnet in your VPC where you want to deploy the optional RDP instance."
default = "subnet-6124e81a"
type = "string"
}

variable "SAPInstanceNum" {
description = "SAP HANA instance number to use for installation and setup, and to open ports for security groups."
type = "string"
default = "00"
}

variable "InstallRDPInstance"  {
type = "string"
description = "Install (Yes) or don't install (No) optional Windows RDP instance."
default = "no"
}

variable "PlacementGroupName" {
type = "string"
description = "Name of an existing placement group where SAP HANA should be deployed (for scale-out deployments."
default = ""
}

variable "windows2012ami" {
type = "string"
default = "ami-01af9070569a8c2a9"
}

variable "amzlinuxami" {
type = "string"
default = "ami-00e782930f1c3dbc7"
}

variable "amzlinuxtype" {
type = "string"
default = "t3.medium"
description = "Instance type for Linuxinstance."
}


variable "rdpinstancetype" {
type = "string"
default = "t3.medium"
description = "Instance type for Windows RDP instance."
}

variable  "keyname" {
type = "string"
default = "test01"
}
