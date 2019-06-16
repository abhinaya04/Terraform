variable "aws_access_key" {
  default= "AKIAI3KBUACQY4BZCGYA"
  type = "string"
  description = "Access key of the AWS Account"
}

variable "aws_secret_key" {
  description = "Secret Access Key of the AWS Account"
  type = "string"
  default = "2PCGltzoQwUaJrZL8v6G4OywRsjNeWH796+F36l9"
}

variable "region" {
  default= "ap-south-1"
  type = "string"
  description = "AWS Region Name"
}

variable "primarysubnet" {
  default = "subnet-6124e81a"
  description = "Select the subnet in which SAP Secondary Node needs to be installed For HA only"
  type = "string"
}

variable "ascssecuritygroup" {
   description = "A list of Security Groups for the instance"
   type = "string"
   default = "sg-cc52c0a6"
}

variable "sapsystemid" {
  description = "Key in SAP SID that you want to install:"
  default = "A41"
  type = "string"
}
variable "os" {
  type = "string"
  default = "RedHatLinux73ForSAP"
}

variable "awsamiregionmap" {
 type = "map"
 default = {
   RedHatLinux73ForSAP = {
    AMI = "SAP-7.3_HVM-20180116-x86_64-1-Hourly2-GP2-b676039c-a4f8-4be7-9866-c804b1ade684-ami-d4ffddae.4"
    ap-northeast-1 = "ami-e5036283"
    ap-northeast-2 = "ami-e0e5468e"
    ap-south-1 = "ami-00e782930f1c3dbc7"
    ap-southeast-1 = "ami-92ef90ee"
    ap-southeast-2 = "ami-f6d62994"
    ca-central-1 = "ami-2a63e64e"
    eu-central-1 = "ami-d866f9b7"
    eu-west-1 = "ami-e365fd9a"
    eu-west-2 = "ami-03fee567"
    eu-west-3 = "ami-7ae85e07"
    sa-east-1 = "ami-0b8ac767"
    us-east-1 = "ami-39f0de43"
    us-east-2 = "ami-bbe4cede"
    us-west-1 = "ami-0be4e66b"
    us-west-2 = "ami-edfa4895"
   }
   RedHatLinux74 = {
    AMI = "RHEL-7.4_HVM-20180122-x86_64-1-Access2-GP2"
    us-east-1 = "ami-c5a094bf"
   }
   RedHatLinux75 = {
    AMI = "RHEL-7.5_HVM-20180813-x86_64-0-Access2-GP2"
    us-east-1 = "ami-0456c465f72bd0c95"
   }
   SuSELinux11SP4 = {
   AMI = "suse-sles-11-sp4-v20180104-hvm-ssd-x86_64"
   ap-northeast-1 = "ami-f7960a91"
   ap-northeast-2 = "ami-afc565c1"
   ap-south-1 = "ami-d22b7fbd"
   ap-southeast-1 = "ami-2644325a"
   ap-southeast-2 = "ami-e32b1680"
   ca-central-1 = "ami-0bd85d6f"
   eu-central-1 = "ami-2b3cac44"
   eu-west-1 = "ami-974cdbee"
   eu-west-2 = "ami-3dc2da59"
   eu-west-3 = "ami-2e1aad53"
   sa-east-1 = "ami-59a8eb35"
   us-east-1 = "ami-3881d042"
   us-east-2 = "ami-22e2c947"
   us-west-1 = "ami-034f4f63"
   us-west-2 = "ami-7eb31906"
   }
 }
 }
