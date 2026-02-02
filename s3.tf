# S3 Bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = "iam-lab-bucket-206868134939"

  tags = {
    Name = "iam-lab-bucket"
  }
}

# Test file to upload
resource "aws_s3_object" "test_file" {
  bucket  = aws_s3_bucket.test_bucket.id
  key     = "test-file.txt"
  content = "If you can read this, GetObject works!"
}
