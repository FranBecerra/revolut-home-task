resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_dynamo_policy"
  role = aws_iam_role.dynamo_adm_role.id
  policy = file("${path.module}/files/policies/policy.json")
}

resource "aws_iam_role" "dynamo_adm_role" {
  name = "dynamodb_admin"
  assume_role_policy = file("${path.module}/files/policies/assume_role_policy.json")
}