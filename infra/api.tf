resource "aws_apigatewayv2_api" "lambda" {
  name          = "lambda_birthday_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "lambda_birthday_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "get_birthday" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.get_user.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}
  //request_tempates is required to explicitly set the statusCode to an integer value of 200
  # request_templates = {
  #  "application/json" = jsonencode({
  #    statusCode = 200
  #  })
  #}

resource "aws_apigatewayv2_integration" "update_birthday" {
  api_id = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.put_user.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get_birthday" {
  api_id            = aws_apigatewayv2_api.lambda.id
  route_key         = "GET /hello/{username}"
  target            = "integrations/${aws_apigatewayv2_integration.get_birthday.id}"
}

resource "aws_apigatewayv2_route" "update_birthday" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "PUT /hello/{username}"
  target    = "integrations/${aws_apigatewayv2_integration.update_birthday.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw_get" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gw_put" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.put_user.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

