############### Begin Access Token Lambda ###############
# lambda config
resource "aws_lambda_function" "auth_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${path.module}/zips/auth.zip"
  function_name = "${module.namespace.namespace}-auth"
  handler       = "auth.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  memory_size   = 128
  source_code_hash = filebase64sha256("${path.module}/zips/auth.zip")
#   depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  environment {
    variables = {
      SECRET_NAME = "foobar",
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
############### End Access Token Lambda ###############

############### Begin Pre-signed URL Lambda ###############
# lambda config
resource "aws_lambda_function" "url_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${path.module}/zips/auth.zip"
  function_name = "${module.namespace.namespace}-url"
  handler       = "url.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  memory_size   = 128
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
  name         = "${module.namespace.namespace}-auth-role-policy"
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

#Mosaify lambda