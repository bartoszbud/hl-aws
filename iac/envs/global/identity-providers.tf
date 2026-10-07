locals {
  iam_identity_provider = {
    github = {
      oidc_provider_url       = "https://token.actions.githubusercontent.com"
      oidc_provider_client_id = "sts.amazonaws.com"
      oidc_provider_name      = "github"
      oidc_provider_purpose   = "GitHub Actions deployment"
    }
  }
}

module "iam-identity-provider" {
  for_each = local.iam_identity_provider
  source   = "../../modules/iam-identity-provider"

  oidc_provider_url       = each.value.oidc_provider_url
  oidc_provider_client_id = each.value.oidc_provider_client_id
  oidc_provider_name      = each.value.oidc_provider_name
  oidc_provider_purpose   = each.value.oidc_provider_purpose
}