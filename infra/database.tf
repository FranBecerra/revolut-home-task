resource "aws_dynamodb_table" "people" {
  name           = "people"
  hash_key       = "username"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "username"
    type = "S"
  }
}
