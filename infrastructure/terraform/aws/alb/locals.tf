locals {
  additional_listener_certificates = merge([
    for listener_key, listener in var.https_listeners : {
      for domain in slice(
        listener.certificate_domains,
        1,
        length(listener.certificate_domains)
      ) :
      "${listener_key}:${domain}" => {
        listener_key = listener_key
        domain       = domain
      }
    }
  ]...)
}
