resource "aws_s3_bucket" "static" {
  bucket = var.s3_name
}


resource "aws_s3_bucket_website_configuration" "static" {
  bucket = aws_s3_bucket.static.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

}
resource "aws_s3_bucket_public_access_block" "static" {
  bucket = aws_s3_bucket.static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "static" {
  bucket = aws_s3_bucket.static.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "AllowGetObjects"
    Statement = [
      {
        Sid       = "AllowPublic"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static.arn}/**"
      }
    ]
  })
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.static.id
  key    = "index.html"
  source = "${path.module}/index.html"
  content_type = "text/html"
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

