resource "aws_s3_bucket" "first-bucket-abbey" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
