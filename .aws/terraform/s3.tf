# add static site config
########## begin s3 static site bucket configuration ##########
resource "aws_s3_bucket" "static_site_bucket" {
  bucket = "${module.namespace.namespace}-static-page"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "static_site_bucket" {
  bucket = aws_s3_bucket.static_site_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "static_site_cors" {
  bucket = aws_s3_bucket.static_site_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["POST", "GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

# allow public access
resource "aws_s3_bucket_public_access_block" "static_site_access" {
  bucket = aws_s3_bucket.static_site_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.static_site_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.static_site_access]
}

resource "aws_s3_bucket_acl" "static_site_acl" {
    bucket = aws_s3_bucket.static_site_bucket.id
    acl    = "public-read"
    depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.static_site_bucket.id
  policy = data.aws_iam_policy_document.allow_public_access.json
}

data "aws_iam_policy_document" "allow_public_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutBucketPolicy"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.static_site_bucket.arn,
      "${aws_s3_bucket.static_site_bucket.arn}/*",
    ]
  }

  depends_on = [aws_s3_bucket_public_access_block.static_site_access]
}
########## end s3 static site bucket configuration ##########

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