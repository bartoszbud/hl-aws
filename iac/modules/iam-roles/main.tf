resource "aws_iam_role" "role" {
  name               = var.name
  description        = var.description
  assume_role_policy = var.assume_role_policy
  tags               = var.tags
}

data "aws_iam_policy" "policy" {
  for_each = toset(var.policies)
  name     = each.value
}

resource "aws_iam_role_policy_attachment" "attached_policy" {
  for_each   = data.aws_iam_policy.policy
  role       = aws_iam_role.role.id
  policy_arn = each.value.arn
}