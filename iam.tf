# IAM Role - EC2 will "become" this identity that is only EC2 can use this role
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
}

# IAM Policy - LEAST PRIVILEGE only read, explicitly deny delete
resource "aws_iam_policy" "s3_read_only" {
  name        = "s3-read-only-policy"
  description = "Read S3, NO delete"

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
}

# Attach policy to role connects the policy to the role
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_s3_reader.name
  policy_arn = aws_iam_policy.s3_read_only.arn
}

# Instance profile - lets EC2 use the role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-reader-profile"
  role = aws_iam_role.ec2_s3_reader.name
}
