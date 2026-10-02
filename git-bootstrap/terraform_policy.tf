locals {

  policy_files = {
    networking = "networking.json"
    compute    = "compute.json"
    database   = "database.json"
    delivery   = "delivery.json"
    monitoring = "monitoring.json"
    security   = "security.json"
    loadbalancing = "loadbalancing.json"
  }

}

resource "aws_iam_policy" "terraform_policies" {

  for_each = local.policy_files

  name = "terraform-${each.key}-policy"

  policy = file(
    "${path.module}/policies/${each.value}"
  )

}