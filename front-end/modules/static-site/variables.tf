variable "site_bucket_name" {
    description = "The name of the S3 Bucket for the site"
}

variable "hosted_zone_name" {
    description = "While not the same as a domain name, e.g. a-hosted-zone (??? I have no idea what I meant to put here)" 
}

variable "ssm_parameter_name" {
    description = "The name of the SSM parameter that holds the certificate"
}