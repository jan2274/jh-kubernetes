###################### S3 for log ######################
resource "aws_s3_bucket" "jh_s3_codebuild" {
  bucket = "jh-s3-codebuild"
}

###################### Role and Policy ######################
# Trust relationship for role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# create role
resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy_document" "codebuild_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:ap-northeast-2:381492128216:network-interface/*"] ###

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"

      values = [
                
        aws_subnet.private[0].arn,
        aws_subnet.private[1].arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.jh_s3_codebuild.arn,
      "${aws_s3_bucket.jh_s3_codebuild.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "codebuild_ecr_policy" {
  name        = "codebuild-ecr-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "codestar-connections:*"
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy" "codebuild_policy" {
  role   = aws_iam_role.codebuild_role.name
  policy = data.aws_iam_policy_document.codebuild_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_ecr_policy.arn
}

###################### codebuild ######################
resource "aws_codebuild_project" "codebuild_imagebuild" {
  name          = "codebuild-imagebuild"
  build_timeout = 5
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.jh_s3_codebuild.id}/build-log"   ###
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/jan2274/jh-kubernetes.git"    ###
    git_clone_depth = 1

    buildspec = templatefile("buildspec_template.yml", {
      ecr_domain = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com",
      region     = data.aws_region.current.name
      image_repo_name = aws_ecr_repository.ecr_repo.name
    })
    
    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "main"

  vpc_config {
    vpc_id = aws_vpc.main.id    ###

    subnets = [
      aws_subnet.private[0].id,  ###
      aws_subnet.private[1].id  ###
    ]

    security_group_ids = [
      aws_security_group.eks_node_sg.id ###
    ]
  }
}