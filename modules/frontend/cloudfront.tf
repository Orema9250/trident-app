resource "aws_cloudfront_origin_access_control" "origin_access_control" {
  name                              = "s3-acesss"
  description                       = "s3 origin access control "
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "cache_policy" {
  name        = "frontend-policy"
  comment     = "frontend cache policy test"
  default_ttl = 3600
  max_ttl     = 86400
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"

    }
    headers_config {
      header_behavior = "none"

    }
    query_strings_config {
      query_string_behavior = "none"

    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }

}

locals {
  s3_origin_id = aws_s3_bucket.frontend.id
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    cache_policy_id        = aws_cloudfront_cache_policy.cache_policy.id
    viewer_protocol_policy = "allow-all"

  }

  ordered_cache_behavior {
    path_pattern           = "/content/immutable/*"
    allowed_methods        = ["GET", "HEAD", ]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    cache_policy_id        = aws_cloudfront_cache_policy.cache_policy.id
    viewer_protocol_policy = "allow-all"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = terraform.workspace
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
