
resource "aws_route53_record" "private" {
  zone_id = var.route53_zone_id != "" ? var.route53_zone_id : data.aws_route53_zone.private.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name = var.api_type == "REST" ? (
      var.endpoint_type == "REGIONAL" ?
      aws_api_gateway_domain_name.rest.regional_domain_name :
      aws_api_gateway_domain_name.rest.cloudfront_domain_name
      ) : (
      aws_apigatewayv2_domain_name.http.domain_name_configuration[0].target_domain_name
    )

    zone_id = var.api_type == "REST" ? (
      var.endpoint_type == "REGIONAL" ?
      aws_api_gateway_domain_name.rest.regional_zone_id :
      aws_api_gateway_domain_name.rest.cloudfront_zone_id
      ) : (
      aws_apigatewayv2_domain_name.http.domain_name_configuration[0].hosted_zone_id
    )

    evaluate_target_health = false
  }

  lifecycle {
    enabled = var.create_route53_record && var.route53_zone_name != ""
  }
}


resource "aws_route53_record" "public" {
  zone_id = var.route53_zone_id != "" ? var.route53_zone_id : data.aws_route53_zone.public.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name = var.api_type == "REST" ? (
      var.endpoint_type == "REGIONAL" ?
      aws_api_gateway_domain_name.rest.regional_domain_name :
      aws_api_gateway_domain_name.rest.cloudfront_domain_name
      ) : (
      aws_apigatewayv2_domain_name.http.domain_name_configuration[0].target_domain_name
    )

    zone_id = var.api_type == "REST" ? (
      var.endpoint_type == "REGIONAL" ?
      aws_api_gateway_domain_name.rest.regional_zone_id :
      aws_api_gateway_domain_name.rest.cloudfront_zone_id
      ) : (
      aws_apigatewayv2_domain_name.http.domain_name_configuration[0].hosted_zone_id
    )

    evaluate_target_health = false
  }

  lifecycle {
    enabled = var.create_route53_record && var.route53_zone_name != ""
  }
}
