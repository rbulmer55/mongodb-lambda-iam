data "aws_caller_identity" "current" {}

resource "aws_iam_role" "mongodb_read_write_access" {
  name = "MongoDBReadWriteAccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "MDB - Access Role ReadWrite"
  })
}
