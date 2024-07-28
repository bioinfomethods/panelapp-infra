resource "aws_ecr_repository" "repo_base" {
  name                 = "${var.stack}_base_${var.env_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = module.site.site_key
  }
}

resource "aws_ecr_repository" "repo_web" {
  name                 = "${var.stack}_web_${var.env_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = module.site.site_key
  }
}

resource "aws_ecr_repository" "repo_worker" {
  name                 = "${var.stack}_worker_${var.env_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = module.site.site_key
  }
}

# data "aws_iam_policy_document" "mcri_ecr_policy_document" {
#   statement {
#     sid    = "new policy"
#     effect = "Allow"
#
#     principals {
#       type        = "AWS"
#       identifiers = [
#         ""
#       ]
#     }
#
#     actions = [
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:BatchGetImage",
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:PutImage",
#       "ecr:InitiateLayerUpload",
#       "ecr:UploadLayerPart",
#       "ecr:CompleteLayerUpload",
#       "ecr:DescribeRepositories",
#       "ecr:GetRepositoryPolicy",
#       "ecr:ListImages",
#       "ecr:DeleteRepository",
#       "ecr:BatchDeleteImage",
#       "ecr:SetRepositoryPolicy",
#       "ecr:DeleteRepositoryPolicy",
#     ]
#   }
# }
#
# resource "aws_ecr_repository_policy" "mcri_ecr_policy" {
#   repository = aws_ecr_repository.mcri_ecr.name
#   policy     = data.aws_iam_policy_document.mcri_ecr_policy_document.json
# }
