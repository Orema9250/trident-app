resource "aws_dynamodb_table" "activities" {
  name         = "cloudtask-activities"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Id"


  attribute {
    name = "Id"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Application = "cloudtask"
  }
}