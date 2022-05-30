variable "assume_role" {
  type        = string
  default     = "ci"
  description = "IAM role assumed by Concourse when running Terraform"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "data_ingress_server_ec2_instance_type" {
  type = map(string)
  default = {
    development = "m5.2xlarge"
    qa          = "m5.2xlarge"
    integration = "m5.2xlarge"
    preprod     = "m5.2xlarge"
    production  = "m5.2xlarge"
  }
}
variable "data_ingress_server_ebs_volume_size" {
  type = map(string)
  default = {
    development = "1000"
    qa          = "1000"
    integration = "1000"
    preprod     = "1000"
    production  = "15000"
  }
}
variable "data_ingress_server_ebs_volume_type" {
  type = map(string)
  default = {
    development = "gp3"
    qa          = "gp3"
    integration = "gp3"
    preprod     = "gp3"
    production  = "gp3"
  }
}
variable "ecs_hardened_ami_id" {
  description = "The AMI ID of the latest/pinned ECS Hardened AMI Image"
  type        = string
  default     = "ami-00b441a83d7d7c8f0"
}

variable "parent_domain_name" {
  description = "parent domain name for monitoring"
  type        = string
  default     = "dataworks.di.dwp.gov.uk"
}

variable "data_ingress_port" {
  type    = number
  default = 8080
}

variable "sft_agent_image_version" {
  description = "image version for the SFT agent"
  type        = map(string)
  default = {
    development = "0.0.37"
    qa          = "0.0.37"
    integration = "0.0.37"
    preprod     = "0.0.37"
    production  = "0.0.37"
  }
}

variable "sft_agent_port" {
  default = 8091
}
variable "test_ami" {
  description = "Defines if cluster should test untested ECS AMI"
  type        = bool
  default     = false
}

variable "task_definition_memory" {
  type = map(string)
  default = {
    development = "10240"
    qa          = "10240"
    integration = "10240"
    preprod     = "26624"
    production  = "26624"
  }
}

variable "task_definition_cpu" {
  type = map(string)
  default = {
    development = "2048"
    qa          = "2048"
    integration = "2048"
    preprod     = "4096"
    production  = "4096"
  }
}
