data "archive_file" "get_user_file" {
  type = "zip"

  source_file = "${path.module}/files/lambda_functions/get_user.py"
  output_path = "${path.module}/files/lambda_get_user.zip"
}

data "archive_file" "put_user_file" {
  type = "zip"

  source_file = "${path.module}/files/lambda_functions/put_user.py"
  output_path = "${path.module}/files/lambda_put_user.zip"
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "lambda-functions"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
  force_destroy = true
}

resource "aws_s3_object" "get_user_file" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "lambda_get_user.zip"
  source = data.archive_file.get_user_file.output_path

  etag = filemd5(data.archive_file.get_user_file.output_path)
}

resource "aws_s3_object" "put_user_file" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "lambda_put_user.zip"
  source = data.archive_file.put_user_file.output_path

  etag = filemd5(data.archive_file.put_user_file.output_path)
}

resource "aws_lambda_function" "get_user" {
  function_name = "GetUser"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = aws_s3_object.get_user_file.key
  handler       = "get_user.lambda_handler"
  role          = aws_iam_role.dynamo_adm_role.arn
  source_code_hash = data.archive_file.get_user_file.output_base64sha256
  runtime = "python3.9"
}

resource "aws_lambda_function" "put_user" {
  function_name = "PutUser"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = aws_s3_object.put_user_file.key
  handler       = "put_user.lambda_handler"
  role          = aws_iam_role.dynamo_adm_role.arn
  source_code_hash = data.archive_file.put_user_file.output_base64sha256
  runtime = "python3.9"
}

resource "aws_iam_policy" "function_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "get_user_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.get_user.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "put_user_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.put_user.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}


resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role = aws_iam_role.dynamo_adm_role.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}