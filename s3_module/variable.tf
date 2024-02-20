variable "aws_region" {
  type        = string
  description = "your desire aws region"
  default     = "us-east-1"
}

variable "random_s3" {
  type = map(bool)
  default = {
    "special" = false
    "upper  " = false
    "numeric" = false
  }
}

variable "tags" {
  type = map(any)
  default = {
    "id"             = "1300"
    "owner"          = "Practical DevOps"
    "teams"          = "PD"
    "environment"    = "dev"
    "project"        = "S3 Backend"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }

}

variable "s3_versioning" {
  type = string
  default = "Enabled"
  
}