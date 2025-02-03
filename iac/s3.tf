resource "aws_s3_bucket" "bucket" {
  bucket = "my-media-streaming-bucket"
}

resource "aws_s3_object" "raw" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "raw/"
}

resource "aws_s3_object" "encoded" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "encoded/"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.bucket.id
  eventbridge = true
}
