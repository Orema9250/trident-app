resource "aws_iam_role_policy_attachment" "terraform_attachments" {

  for_each = aws_iam_policy.terraform_policies

  role = "terraform-githubrole"

  policy_arn = each.value.arn

}