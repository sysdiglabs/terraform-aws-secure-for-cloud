locals {
  skip_tls_flag = var.verify_ssl ? "--sysdig-skip-tls" : ""
}

data "aws_ssm_parameter" "endpoint" {
  name = var.ssm_endpoint
}

data "aws_ssm_parameter" "api_token" {
  name = var.ssm_token
}

resource "aws_cloudwatch_log_group" "log" {
  name_prefix       = "${var.naming_prefix}-CloudScanning-BuildProject"
  retention_in_days = var.log_retention
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "logs_publisher" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.log.arn,
      "${aws_cloudwatch_log_group.log.arn}:*",
    ]
  }
}

data "aws_iam_policy_document" "parameter_reader" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [data.aws_ssm_parameter.endpoint.arn, data.aws_ssm_parameter.api_token.arn]
  }

}

resource "aws_iam_role" "service" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  path               = "/"

  inline_policy {
    name   = "LogsPublisher"
    policy = data.aws_iam_policy_document.logs_publisher.json
  }

  inline_policy {
    name   = "ParameterReader"
    policy = data.aws_iam_policy_document.parameter_reader.json
  }
}

resource "aws_codebuild_project" "build_project" {
  name         = "${var.naming_prefix}-CloudScanningProject"
  description  = "CodeBuild project which scans images using inline technology"
  service_role = aws_iam_role.service.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.log.id
      status     = "ENABLED"
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = <<EOF
version: 0.2

env:
  variables:
    SCAN_IMAGE_NAME: "quay.io/sysdig/secure-inline-scan:2"
  parameter-store:
    SYSDIG_SECURE_ENDPOINT: ${data.aws_ssm_parameter.endpoint.name}
    SYSDIG_SECURE_TOKEN: ${data.aws_ssm_parameter.api_token.name}

phases:
  build:
    commands:
    - |
      if [ -z "$REGISTRY_AUTH" ]; then
        docker run --rm -e SYSDIG_ADDED_BY=$SYSDIG_ADDED_BY $SCAN_IMAGE_NAME -s $SYSDIG_SECURE_ENDPOINT ${local.skip_tls_flag} --sysdig-token $SYSDIG_SECURE_TOKEN $IMAGE_TO_SCAN --annotations=aws-account=$EVENT_ACCOUNT,aws-region=$EVENT_REGION
      else
        docker run --rm -e SYSDIG_ADDED_BY=$SYSDIG_ADDED_BY $SCAN_IMAGE_NAME -s $SYSDIG_SECURE_ENDPOINT ${local.skip_tls_flag} --sysdig-token $SYSDIG_SECURE_TOKEN --registry-auth-basic "$(echo $REGISTRY_AUTH | base64 -d)" $IMAGE_TO_SCAN --annotations=aws-account=$EVENT_ACCOUNT,aws-region=$EVENT_REGION
      fi
EOF
  }
}
