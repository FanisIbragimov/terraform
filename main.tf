terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.72.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  access_key = "AKIAQ3KDCMCSDH7GNY7I"
  secret_key = "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"
}
resource "aws_s3_bucket" "my-s3-bucket" {
  bucket_prefix = var.bucket_prefix
  acl = var.acl
  
   versioning {
    enabled = var.versioning
  }
  
  tags = var.tags
}

data "aws_ami" "debian_buster" {
  filter {
    name = "name"
    values = [ "debian-10-amd64-*" ]
  }
  most_recent = true
  owners = [
    "136693071363"
  ] // https://wiki.debian.org/Cloud/AmazonEC2Image
}

locals {
web_instance_type_map = {
 stage = "t2.micro"
 prod = "t2.large"
}
instances = {
 "t2.micro" = data.aws_ami.debian_buster.id
 "t2.large" = data.aws_ami.debian_buster.id
}
}
resource "aws_instance" "web" {
  for_each = local.instances
  ami = each.value
  instance_type = each.key
  lifecycle {
    create_before_destroy = true
  }
}

