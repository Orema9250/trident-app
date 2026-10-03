output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.s3_distribution.id
}