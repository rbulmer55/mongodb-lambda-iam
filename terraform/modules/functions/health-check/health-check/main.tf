
resource "aws_iam_role" "health_check_lambda_role" {
  name               = "HealthCheckLambdaRole"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "health_check_lambda_role_policy" {

  name        = "HealthCheckLambdaRolePolicy"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
    {
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
   },
   {
      "Effect": "Allow",
      "Action": [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    },
    {  
        "Effect": "Allow",
        "Action": [  
          "sts:AssumeRole",  
          "sts:GetCallerIdentity"  
        ] ,
        "Resource": "*"  
    }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "health_check_attach_policy_to_role" {
  role       = aws_iam_role.health_check_lambda_role.name
  policy_arn = aws_iam_policy.health_check_lambda_role_policy.arn
}

data "archive_file" "zip_health_check" {
  type        = "zip"
  source_file = "${path.module}/../../dist/health-check-lambda.js"
  output_path = "${path.module}/health-check-lambda.zip"
}

resource "aws_lambda_function" "health_check_function" {
  filename         = data.archive_file.zip_health_check.output_path
  function_name    = var.function_name
  role             = aws_iam_role.health_check_lambda_role.arn
  handler          = "health-check-lambda.handler"
  runtime          = "nodejs20.x"
  depends_on       = [aws_iam_role_policy_attachment.health_check_attach_policy_to_role]
  source_code_hash = data.archive_file.zip_health_check.output_base64sha256
  timeout          = 10
  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [var.atlas_security_group_id]
  }
  environment {
    variables = {
      MDB_ACCESS_ROLE_ARN : var.access_role_arn
      DB_NAME : "Admin"
      MDB_CLUSTER_HOSTNAME : var.cluster_hostname
    }
  }
  tags = var.tags
}
