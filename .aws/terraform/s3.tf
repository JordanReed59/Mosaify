########## begin s3 upload/download bucket configuration ##########
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
########## end s3 upload/download bucket configuration ##########