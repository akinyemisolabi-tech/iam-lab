# IAM Role - EC2 will assume this identity
resource "aws_iam_role" "ec2_s3_reader" {
  name = "ec2-s3-reader-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "iam-lab-role"
  }
}

# IAM Policy - Least Privilege (read yes, delete no)
resource "aws_iam_policy" "s3_read_only" {
  name        = "s3-read-only-policy"
  description = "Allow S3 read, deny S3 delete"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowRead"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.test_bucket.arn,
          "${aws_s3_bucket.test_bucket.arn}/*"
        ]
      },
      {
        Sid      = "DenyDelete"
        Effect   = "Deny"
        Action   = ["s3:DeleteObject", "s3:DeleteBucket"]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "iam-lab-policy"
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_s3_reader.name
  policy_arn = aws_iam_policy.s3_read_only.arn
}

# Instance profile - allows EC2 to use the role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-reader-profile"
  role = aws_iam_role.ec2_s3_reader.name

  tags = {
    Name = "iam-lab-instance-profile"
  }
}
