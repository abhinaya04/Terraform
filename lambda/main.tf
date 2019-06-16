provider "aws" {
  region     = "${var.region}"
}

resource "aws_iam_policy" "lambda_edge_policy" {
  name        = "${var.policy_name}"
  path        = "/"
  description = "Lambda Edge Policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "lambda_edge_role" {
  name = "${var.role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-cdn-redirect-policy-attachment" {
    role = "${aws_iam_role.lambda_edge_role.name}"
    policy_arn = "${aws_iam_policy.lambda_edge_policy.arn}"
}

resource "null_resource" "lambda_file" {
  provisioner "local-exec" {
    command = "zip index.zip index.js"
  }
}

resource "aws_lambda_function" "redirect_to_https" {

  filename         = "index.zip"
  function_name    = "${var.function_name}"
  role             = "${aws_iam_role.lambda_edge_role.arn}"
  handler          = "index.handler"
  runtime          = "nodejs6.10"

  tags {
    "lambda-console:blueprint" = "cloudfront-modify-response-header"
  }

  depends_on = ["null_resource.lambda_file"]
}

resource "aws_cloudfront_distribution" "redirect_to_https" {
  origin {
    domain_name = "${var.domain_name}"
    origin_id   = "${var.origin_id}"
    custom_origin_config {

       origin_ssl_protocols = ["TLSv1.2", "TLSv1.1", "TLSv1"]
       origin_protocol_policy = "http-only"
       http_port = 80
       https_port = 443
    }
  }
  enabled             = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "${var.viewer_protocol_policy}"
    target_origin_id = "${var.origin_id}"
    lambda_function_association {
        event_type   = "viewer-request"
        lambda_arn   = "${aws_lambda_function.redirect_to_https.qualified_arn}"
        include_body = false
    }
  forwarded_values {
    query_string = false
      cookies {
        forward = "none"
      }
  }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

