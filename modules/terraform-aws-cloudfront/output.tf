output "cloudfront_url" {
  value = aws_cloudfront_distribution.static.domain_name
}