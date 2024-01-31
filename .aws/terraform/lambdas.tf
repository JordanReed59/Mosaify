############### Begin Access Token Lambda ###############
# lambda config
resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "${module.namespace.namespace}-auth"
  handler       = "auth.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  source_code_hash = filebase64sha256("${path.module}/../../src/backend/auth/auth.zip") #in pipeline will mv zip to backend folder
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
resource "aws_iam_role" "lambda_role" {
  name   = "${module.namespace.namespace}-auth-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json 
}

data "aws_iam_policy_document" "lambda_role" {
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

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role        = aws_iam_role.lambda_role.name
  policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
  name         = "${module.namespace.namespace}-auth-role-policy"
  description  = "AWS IAM Policy for Mosaify auth lambda"
  policy       = data.aws_iam_policy_document.role_policy.json
}


data "aws_iam_policy_document" "role_policy" {
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
# Pre-signed url lambda

#Mosaify lambda