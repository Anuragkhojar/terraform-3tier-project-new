variable "vpc_id" {}
variable "subnets" { type = list(string) }
variable "instance_type" {}
variable "ami_id" {}
variable "desired_capacity" {}
variable "min_size" {}
variable "max_size" {}
variable "sg_ids" { type = list(string) }
variable "user_data" { default = "#!/bin/bash\nyum install -y python3\n" }
