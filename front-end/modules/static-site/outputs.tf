output "s3_bucket_website_domain" {
  value = "${aws_s3_bucket.site_bucket.website_domain}"
}

output "s3_bucket_hosted_zone_id" {
    value = "${aws_s3_bucket.site_bucket.hosted_zone_id}"
}

output "s3_bucket_domain_name" {
  value = "${aws_s3_bucket.site_bucket.bucket_domain_name}"
}

output "bucket_regional_domain_name" {
  value = "${aws_s3_bucket.site_bucket.bucket_regional_domain_name}"
}