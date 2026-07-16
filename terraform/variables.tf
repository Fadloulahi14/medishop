variable "project_name" {
  type    = string
  default = "medishop-todo"
}

variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "availability_zone" {
  type    = string
  default = "eu-west-3a"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type = string
}

variable "admin_cidr" {
  type        = string
  description = "IP publique admin au format x.x.x.x/32"
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "associate_front_eip" {
  type    = bool
  default = false
}

variable "ami_id" {
  type        = string
  default     = ""
  description = "AMI Ubuntu optionnelle. Laisser vide pour selectionner automatiquement Ubuntu 24.04 LTS."
}

variable "root_volume_size" {
  type    = number
  default = 12
}
