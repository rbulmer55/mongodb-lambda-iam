data "aws_caller_identity" "current" {}

resource "aws_iam_role" "mongodb_read_write_access" {
  name = "MongoDBReadWriteAccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "MDB - Access Role ReadWrite"
  })
}
