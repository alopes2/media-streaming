locals {
  origin_id = "MediaStreaming"
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "MediaStreaming"
  description                       = "MediaStreaming Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.origin_id
    origin_path              = "/${trimsuffix(aws_s3_object.encoded.key, "/")}"
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "My MediaStreaming Distribution"

  # logging_config {
  #   include_cookies = false
  #   bucket          = "mylogs.s3.amazonaws.com"
  #   prefix          = "myprefix"
  # }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    cache_policy_id = aws_cloudfront_cache_policy.website.id

    viewer_protocol_policy = "redirect-to-https"

    response_headers_policy_id = aws_cloudfront_response_headers_policy.CORS.id
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Sends to the origin and caches it
resource "aws_cloudfront_cache_policy" "website" {
  name = "cache_policy"

  parameters_in_cache_key_and_forwarded_to_origin {
    headers_config {
      header_behavior = "none"
    }
    cookies_config {
      cookie_behavior = "all"
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

# Sends to the origin but doesn't cache it
# Must be set with a Cache Policy
# resource "aws_cloudfront_origin_request_policy" "website_origin_request_policy" {
#   name = "origin_request_policy"
#   headers_config {
#     header_behavior = "allViewer"
#   }

#   cookies_config {
#     cookie_behavior = "all"
#   }

#   query_strings_config {
#     query_string_behavior = "all"
#   }
# }

# If CORS is needed, add this
resource "aws_cloudfront_response_headers_policy" "CORS" {
  name = "CORS"
  cors_config {
    access_control_allow_credentials = true
    origin_override                  = true
    access_control_allow_headers {
      items = ["Content-Type", "Authorization"]
    }

    access_control_allow_methods {
      items = ["GET"]
    }

    access_control_allow_origins {
      items = ["http://localhost:3000", "https://localhost:3000"]
    }
  }
}
