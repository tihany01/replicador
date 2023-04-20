data "aws_iam_policy_document" "asumir-policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "s3-replicador-de-rol" {
  name = "s3-replicador-rol"
  assume_role_policy = data.aws_iam_policy_document.asumir-policy.json
}
#-------------------------------------------------------------------------------
data "aws_iam_policy_document" "document-policy" {
  statement {
    effect   = "Allow"
    actions   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
    resources = [aws_s3_bucket.myoriginal.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.myoriginal.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.myreplicador.arn}/*"]
  }
}
resource "aws_iam_policy" "s3-replicador-de-policy" {
  name   = "s3-replicador-policy"
  policy = data.aws_iam_policy_document.document-policy.json
}

resource "aws_iam_role_policy_attachment" "union" {
  role       = aws_iam_role.s3-replicador-de-rol.name
  policy_arn = aws_iam_policy.s3-replicador-de-policy.arn
}
