# OIDC Providers
resource "aws_iam_openid_connect_provider" "this" {
  for_each = var.oidc_providers

  url             = each.value.url
  client_id_list  = each.value.client_id_list
  thumbprint_list = length(each.value.thumbprint_list) > 0 ? each.value.thumbprint_list : ["0000000000000000000000000000000000000000"]


  tags = {
    Name = each.key
  }
}

# SAML Providers
resource "aws_iam_saml_provider" "this" {
  for_each = var.saml_providers

  name                   = each.key
  saml_metadata_document = each.value.saml_metadata_document

  tags = {
    Name = each.key
  }
}
