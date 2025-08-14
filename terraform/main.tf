provider "aws" {
  region = "ap-southeast-1"
}

# S3 Bucket creation
resource "aws_s3_bucket" "sample" {
  bucket = "mysampleterraformbucket"
}

# Allow public access settings
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.sample.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.sample.id

  index_document {
    suffix = "index.html"
  }
}

# Public read-only bucket policy
data "aws_iam_policy_document" "public_read" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.sample.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_anywhere" {
  bucket = aws_s3_bucket.sample.id
  policy = data.aws_iam_policy_document.public_read.json
}

# Upload files from local "upload" folder
resource "aws_s3_object" "website_files" {
  for_each = fileset("./upload", "*")

  bucket = aws_s3_bucket.sample.id
  key    = each.value
  source = "./upload/${each.value}"

  etag = filemd5("./upload/${each.value}")
}

# CloudFront Creation