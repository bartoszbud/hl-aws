resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url            = var.oidc_provider_url
  client_id_list = [var.oidc_provider_client_id]

  tags = {
    Name    = var.oidc_provider_name
    Purpose = var.oidc_provider_purpose
  }
}