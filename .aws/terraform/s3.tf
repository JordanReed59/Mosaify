########## begin s3 upload/download bucket configuration ##########
# upload bucket
resource "aws_s3_bucket" "mosaify_upload_bucket" {
  bucket = "${module.namespace.namespace}-image-upload-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "upload_expiration" {
  bucket = aws_s3_bucket.mosaify_upload_bucket.id

  rule {
    id = "expiration-rule"
    filter {}
    expiration {
      days = 1
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "upload_cors" {
  bucket = aws_s3_bucket.mosaify_upload_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

# download bucket
resource "aws_s3_bucket" "mosaify_download_bucket" {
  bucket = "${module.namespace.namespace}-image-download-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "download_expiration" {
  bucket = aws_s3_bucket.mosaify_download_bucket.id

  rule {
    id = "expiration-rule"
    filter {}
    expiration {
      days = 1
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "download_cors" {
  bucket = aws_s3_bucket.mosaify_download_bucket.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}
########## end s3 upload/download bucket configuration ##########