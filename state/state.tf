provider aws {
  region = "eu-west-2"
}
 
#####################################################
### This creates a s3 bucket and a dynamoDB table ###
#####################################################
 
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-digital-summit-demo"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
 
resource "aws_dynamodb_table" "terraform_lock_state" {
  name         = "dynamoDB_to_lock_terraform_state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}