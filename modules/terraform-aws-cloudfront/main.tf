locals {
  s3_origin_id   = "${var.s3_name}-origin"
  s3_domain_name = "${var.s3_name}.s3-website.${var.region}.amazonaws.com"
}

resource "aws_cloudfront_distribution" "static" {
  
  enabled = true
  
  origin {
    origin_id                = local.s3_origin_id
    domain_name              = local.s3_domain_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols     = ["SSLv3" ,"TLSv1","TLSv1.1","TLSv1.2"]
    }
  }

  default_cache_behavior {
    
    target_origin_id = local.s3_origin_id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_200"
  
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx_error_alarm" {
  alarm_name          = "CloudFront-5xx-Error-Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Triggers if CloudFront 5xx error rate exceeds 5 in the last 5 minutes."

  dimensions = {
    DistributionId = aws_cloudfront_distribution.static.id
  }

  actions_enabled = true

  alarm_actions = [aws_sns_topic.cloudfront_alarm_topic.arn]
}

resource "aws_sns_topic" "cloudfront_alarm_topic" {
  name = "cloudfront_alarm_topic"
}

resource "aws_sns_topic_subscription" "cloudfront_alarm_email" {
  topic_arn = aws_sns_topic.cloudfront_alarm_topic.arn
  protocol  = "email"
  endpoint  = "prakash8807776601@gmail.com"  
}

# resource "null_resource" "invalidate_index_html" {
#   triggers = {
#     index_checksum = filemd5("${path.module}/index.html")
#   }

#   provisioner "local-exec" {
#     command = <<EOT
#       aws cloudfront create-invalidation \
#         --distribution-id ${aws_cloudfront_distribution.static.id} \
#         --paths "/index.html"
#     EOT
#   }
# }