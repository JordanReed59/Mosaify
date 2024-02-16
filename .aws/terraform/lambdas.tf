############### Create Container Repo ###############
resource "aws_ecr_repository" "repo" {
  name                 = "${module.namespace.namespace}-container-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

# lifecycle policies for untagged images
resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  repository = aws_ecr_repository.repo.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid       = "ExpireImages"
    actions   = ["ecr:BatchDeleteImage"]
    resources = [aws_ecr_repository.repo.arn]

    condition {
      test     = "Null"
      variable = "ecr:ResourceTag"
      values   = [ "" ]
    }

    condition {
      test     = "NumericGreaterThanEquals"
      variable = "ecr:ImageAgeInDays"
      values   = ["1"]
    }
  }
}


############### Begin Access Token Lambda ###############
# lambda config
resource "aws_lambda_function" "auth_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "${path.module}/zips/auth.zip"
  function_name    = "${module.namespace.namespace}-auth"
  handler          = "auth.lambda_handler"
  role             = aws_iam_role.auth_lambda_role.arn
  runtime          = "python3.12"
  memory_size      = 128
  tags             = module.namespace.tags
  source_code_hash = filebase64sha256("${path.module}/zips/auth.zip")
#   depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  environment {
    variables = {
      SECRET_NAME = "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:mosaify-dev-feature-mos-6-SPOTIFY_CLIENT_CREDENTIALS-91cBdn",
      REGION = var.region,
      TOKEN_URL = "https://accounts.spotify.com/api/token"
    }
  }
}

# lambda role
resource "aws_iam_role" "auth_lambda_role" {
  name   = "${module.namespace.namespace}-auth-role"
  assume_role_policy = data.aws_iam_policy_document.auth_lambda_role_trust.json 
}

data "aws_iam_policy_document" "auth_lambda_role_trust" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_auth_role" {
  role        = aws_iam_role.auth_lambda_role.name
  policy_arn  = aws_iam_policy.iam_policy_for_auth_lambda.arn
}

resource "aws_iam_policy" "iam_policy_for_auth_lambda" {
  name         = "${module.namespace.namespace}-auth-role-policy"
  description  = "AWS IAM Policy for Mosaify auth lambda"
  policy       = data.aws_iam_policy_document.auth_role_policy.json
}


data "aws_iam_policy_document" "auth_role_policy" {
  statement {
    sid       = "CreatLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
  statement {
      sid       =  "ReadSecret"
      effect    =  "Allow"
      actions   =  ["secretsmanager:GetSecretValue"]
      resources =  ["arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:mosaify-dev-feature-mos-6-SPOTIFY_CLIENT_CREDENTIALS-91cBdn"]
    }
}
############### End Access Token Lambda ###############


############### Begin Pre-signed URL Lambda ###############
# lambda config
resource "aws_lambda_function" "url_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "${path.module}/zips/auth.zip"
  function_name    = "${module.namespace.namespace}-url"
  handler          = "url.lambda_handler"
  role             = aws_iam_role.url_lambda_role.arn
  runtime          = "python3.12"
  memory_size      = 128
  tags             = module.namespace.tags
  source_code_hash = filebase64sha256("${path.module}/zips/url.zip")
#   depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  environment {
    variables = {
      BUCKET_NAME = "foobar"
    }
  }
  
}

# lambda role
resource "aws_iam_role" "url_lambda_role" {
  name   = "${module.namespace.namespace}-url-role"
  assume_role_policy = data.aws_iam_policy_document.url_lambda_role_trust.json 
}

data "aws_iam_policy_document" "url_lambda_role_trust" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "_attach_iam_policy_to_iam_url_role" {
  role        = aws_iam_role.url_lambda_role.name
  policy_arn  = aws_iam_policy.iam_policy_for_url_lambda.arn
}

resource "aws_iam_policy" "iam_policy_for_url_lambda" {
  name         = "${module.namespace.namespace}-url-role-policy"
  description  = "AWS IAM Policy for Mosaify url lambda"
  policy       = data.aws_iam_policy_document.url_role_policy.json
}


data "aws_iam_policy_document" "url_role_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}
############### End Pre-signed URL Lambda ###############


############### Begin Mosaify Lambda ###############
# image
data "aws_ecr_image" "mosaify_image" {
  repository_name = aws_ecr_repository.repo.name
  image_tag       = "mosaify"
}

# lambda config
resource "aws_lambda_function" "mosaify_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  function_name    = "${module.namespace.namespace}-mosaify"
  role             = aws_iam_role.mosaify_lambda_role.arn
  package_type     = "Image"
  image_uri        = data.aws_ecr_image.mosaify_image.image_uri
  memory_size      = 128
  tags             = module.namespace.tags
  timeout          = 300
  source_code_hash = trimprefix(data.aws_ecr_image.mosaify_image.id, "sha256:")
  environment {
    variables = {
      UPLOAD_BUCKET_NAME = "mosaify-dev-feature-mos-5-image-upload-bucket",
      DOWNLOAD_BUCKET_NAME = "mosaify-dev-feature-mos-5-image-download-bucket"
    }
  }
  
}

# lambda role
resource "aws_iam_role" "mosaify_lambda_role" {
  name   = "${module.namespace.namespace}-mosaify-role"
  assume_role_policy = data.aws_iam_policy_document.mosaify_lambda_role_trust.json 
}

data "aws_iam_policy_document" "mosaify_lambda_role_trust" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "_attach_iam_policy_to_iam_mosaifyl_role" {
  role        = aws_iam_role.mosaify_lambda_role.name
  policy_arn  = aws_iam_policy.iam_policy_for_mosaify_lambda.arn
}

resource "aws_iam_policy" "iam_policy_for_mosaify_lambda" {
  name         = "${module.namespace.namespace}-mosaify-role-policy"
  description  = "AWS IAM Policy for Mosaify image processing lambda"
  policy       = data.aws_iam_policy_document.mosaify_role_policy.json
}


data "aws_iam_policy_document" "mosaify_role_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
  statement {
    sid       =  "GetObject"
    effect    =  "Allow"
    actions   =  ["s3:GetObject"]
    resources =  ["arn:aws:s3:::mosaify-dev-feature-mos-5-image-upload-bucket", "arn:aws:s3:::mosaify-dev-feature-mos-5-image-upload-bucket/*"]
  }
  statement {
    sid       =  "PutObject"
    effect    =  "Allow"
    actions   =  ["s3:PutObject"]
    resources =  ["arn:aws:s3:::mosaify-dev-feature-mos-5-image-download-bucket", "arn:aws:s3:::mosaify-dev-feature-mos-5-image-download-bucket/*"]
  }
}
############### End Mosaify Lambda ###############

############### Begin Option Lambda ###############
# lambda config
resource "aws_lambda_function" "option_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = "${path.module}/zips/option.zip"
  function_name    = "${module.namespace.namespace}-option"
  handler          = "option.lambda_handler"
  role             = aws_iam_role.option_lambda_role.arn
  runtime          = "python3.12"
  memory_size      = 128
  tags             = module.namespace.tags
  source_code_hash = filebase64sha256("${path.module}/zips/option.zip")
}

# lambda role
resource "aws_iam_role" "option_lambda_role" {
  name   = "${module.namespace.namespace}-option-role"
  assume_role_policy = data.aws_iam_policy_document.option_lambda_role_trust.json 
}

data "aws_iam_policy_document" "option_lambda_role_trust" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "_attach_iam_policy_to_iam_optionl_role" {
  role        = aws_iam_role.option_lambda_role.name
  policy_arn  = aws_iam_policy.iam_policy_for_option_lambda.arn
}

resource "aws_iam_policy" "iam_policy_for_option_lambda" {
  name         = "${module.namespace.namespace}-option-role-policy"
  description  = "AWS IAM Policy for Mosaify option lambda"
  policy       = data.aws_iam_policy_document.option_role_policy.json
}


data "aws_iam_policy_document" "option_role_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}
############### End Option Lambda ###############