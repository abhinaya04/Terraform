variable "aws_access_key" {
  default= ""
  type = "string"
  description = "Access key of the AWS Account"
}

variable "aws_secret_key" {
  description = "Secret Access Key of the AWS Account"
  type = "string"
  default     = ""
}
variable "keyname" {
  default = ""
  description = "Name of an existing Amazon EC2 key pair. All instances will launch with this key pair."
  type = "string"
}

variable "region" {
  default= "ap-south-1"
  type = "string"
  description = "AWS Region Name"
}

variable "aztodeploy" {
  default = "ap-south-1a"
  type = "string"
  description = "Which AZ should the system will be deployed in:"
}

variable "kmskeyid"  {
    default = "arn:aws:kms:us-east-1:583462561139:key/11388651-6e13-4ffe-a63a-9209b562ae42"
    type = "string"
    description = "KMS Key ID that will be used for SAP:"
}

variable "vitlaizeid" {
  default = "366405"
  description = "Vitalize Id of TCWS App Role Automation(Cloud Project Form)"
  type = "string"
}

variable "autorecoverydb" {
  type = "string"
  default = false
}

variable "needbackupvol" {
  type = "string"
  default = true
}

variable "needcustvol" {
  type = "string"
  default = false
}

variable "needexportvol" {
  type = "string"
  default = true
}

variable "sid" {
  type = "string"
  default = "RPX"
  description = "SAP system ID for installation and setup."
}





