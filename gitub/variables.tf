
variable "masternode" {
  description = "The CIDR block for the VPC"
  default     = "agility11-master"
}

variable "workernode1" {
  description = "The CIDR block for the VPC"
  default     = "agility11-worker1"
}

variable "workernode2" {
  description = "The CIDR block for the VPC"
  default     = "agility11-worker2"
}


variable "management_vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "prod_workload_vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "20.0.0.0/16"
}

variable "non-prod_workload_vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "30.0.0.0/16"
}

variable "public_subnets_mngmt" {
  description = "A list of public subnets cidr inside the VPC."
  default     = "10.0.1.0/24"

}

variable "private_subnets_mngmt" {
  description = "A list of public subnets cidr inside the VPC."
  default     = "10.0.2.0/24"

}

variable "public_subnets_prod" {
  description = "A list of public subnets cidr inside the VPC."
  default     = ["20.0.1.0/24","20.0.2.0/24"]

}

variable "private_subnets_prod" {
  description = "A list of private subnets cidr inside the VPC."
  default     = ["20.0.3.0/24"]
}

variable "public_subnets_non-prod" {
  description = "A list of public subnets cidr inside the VPC."
  default     = ["30.0.1.0/24","30.0.2.0/24"]

}

variable "private_subnets_non-prod" {
  description = "A list of private subnets cidr inside the VPC."
  default     = ["30.0.3.0/24"]
}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = false
}

variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = "aws-terraform"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {
          "CreatedBy" = "Chella" 
          "Project" = "Agility SPARK GIGA"
  }
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {
        "CreatedBy" = "Abhinaya"
        "Project" = "Agility SPARK GIGA"
  }
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  default     = {
        "CreatedBy" = "Abhinaya"
        "Project" = "Agility SPARK GIGA"
  }
}

variable "access_key" {
  description = "AWS access key"
  default = "AKIAJI4INTOM6BXDWR3A"
}

variable "secret_key" {
  description = "AWS secret access key"
  default = "WfUf+j2fPB9VGg1qsWJxSMS0FUxnQrW+tSurofSC"
}

variable "region"     {
  description = "AWS region to host your network"
  default = "ap-northeast-2"
}
