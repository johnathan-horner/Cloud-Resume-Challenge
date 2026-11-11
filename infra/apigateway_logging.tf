# Account-level setting: the role API Gateway uses to write execution logs to
# CloudWatch in this region. One per account and region, shared by every REST API.
# The previous role came from the EDA-Project workshop stack and was deleted with it.

resource "aws_iam_role" "apigateway_cloudwatch" {
  name        = "apigateway-cloudwatch-logs"
  description = "Lets API Gateway write execution logs to CloudWatch Logs (account setting, us-east-1)"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apigateway_cloudwatch" {
  role       = aws_iam_role.apigateway_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.apigateway_cloudwatch.arn

  depends_on = [aws_iam_role_policy_attachment.apigateway_cloudwatch]
}
