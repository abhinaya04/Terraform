variable "region" {
 default = "us-east-1"
}

variable "policy_name" {
 default = "lak2_lambda_edge_policy"
}

variable "role_name" {
 default = "lak2_lambda_edge_role"
}

variable "function_name" {
 default = "lak2_redirect_to_https"
}

#Cloud Front protocol for redirection from http to https
variable "viewer_protocol_policy" {
 default = "redirect-to-https"
}

#CF assumes that below domain exist already
variable "domain_name" {
 default = ""
}

variable "origin_id" {
 default = ""
}
