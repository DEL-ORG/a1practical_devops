resource "aws_s3_bucket" "practical_s3_backend" {
  bucket = format("%s-${random_string.practical_random_s3.result}-statefile", var.tags["id"])

  tags = var.tags
}

resource "random_string" "practical_random_s3" {
  length  = 5
  special = var.random_s3["special"]
  upper   = var.random_s3["upper"]
  numeric = var.random_s3["numeric"]
}

resource "aws_s3_bucket_versioning" "practical_s3_versioning" {
  bucket = aws_s3_bucket.practical_s3_backend.id
  versioning_configuration {
    status = var.s3_versioning
  }
}

resource "aws_dynamodb_table" "practical_dynamodb" {
  name             = format("dynamodb-${random_string.practical_random_s3.result}-%s", var.tags["id"])
  hash_key         = "BEWARE"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "BEWARE"
    type = "S"
  }

  
}

