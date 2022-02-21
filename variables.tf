# This file is the variable file which can be customized as per your deployment. 


# Provide the access key to your AWS account
variable "access_key" {
  description = "access key to AWS account"
  default     = "XXXX"
}

# Provide the secret key to your AWS account
variable "secret_key" {
  description = "secret key to AWS account"
  default     = "XXXX"
}

# Select the region required, make sure the AMI is valid for that region.
variable "region" {
  description = "Regions supported"
  default     = "ap-northeast-1"
}

variable "aws_az1" {
  default = "ap-northeast-1a"
}

variable "aws_az2" {
  default = "ap-northeast-1c"
}

variable "f5_username" {
  description = "F5 username"
  default     = "admin"
}

variable "f5_ami_search_name" {
  description = "BIG-IP AMI name to search for"
  type        = string
  default     = "F5 BIGIP-* PAYG-Best 200Mbps*"
}

## Please check and update the latest DO URL from https://github.com/F5Networks/f5-declarative-onboarding/releases
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable "DO_URL" {
  description = "URL to download the BIG-IP Declarative Onboarding module"
  type        = string
  default     = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.27.0/f5-declarative-onboarding-1.27.0-6.noarch.rpm"
}

variable "DO_VER"{
  description = "DO_VER"
  default = "v1.27.0"
}

## Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable "AS3_URL" {
  description = "URL to download the BIG-IP Application Service Extension 3 (AS3) module"
  type        = string
  default     = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.34.0/f5-appsvcs-3.34.0-4.noarch.rpm"
}

variable "AS3_VER"{
  description = "AS3_VER"
  default = "v3.34.0"
}


## Please check and update the latest TS URL from https://github.com/F5Networks/f5-telemetry-streaming/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable "TS_URL" {
  description = "URL to download the BIG-IP Telemetry Streaming module"
  type        = string
  default     = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.26.0/f5-telemetry-1.26.0-3.noarch.rpm"
}

variable "TS_VER"{
  description = "TS_VER"
  default = "v1.26.0"
}

## Please check and update the latest Failover Extension URL from https://github.com/f5devcentral/f5-cloud-failover-extension/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable "CFE_URL" {
  description = "URL to download the BIG-IP Cloud Failover Extension module"
  type        = string
  default     = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.10.0/f5-cloud-failover-1.10.0-0.noarch.rpm"
}

variable "CFE_VER"{
  description = "CFE_VER"
  default = "v1.10.0"
}

## Please check and update the latest FAST URL from https://github.com/F5Networks/f5-appsvcs-templates/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable "FAST_URL" {
  description = "URL to download the BIG-IP FAST module"
  type        = string
  default     = "https://github.com/F5Networks/f5-appsvcs-templates/releases/download/v1.15.0/f5-appsvcs-templates-1.15.0-1.noarch.rpm"
}

variable "FAST_VER"{
  description = "CFE_VER"
  default = "v1.15.0"
}


variable "management_subnet_cidr" {
  description = "CIDR for the Management subnet"
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  default     = "10.0.3.0/24"
}


# Provide the EC2 instance type
variable "instance_type" {
  description = "instance type for EC2"
  default     = "m5.large"
}

# Please assign unique indentifier so thate the resources not conflicting
variable "prefix" {
  description = "prefix for resources created"
  default     = "fwinata_testing"
}

resource "random_id" "random-string" {
  byte_length = 4
}

# Please assign AWS keypair so that you can have access to the EC2 later
variable "key_name" {
  description = "PEM key to ssh later"
  default     = "fwinata-key-example"
}

