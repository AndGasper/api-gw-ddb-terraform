# S3 STUFF
resource "aws_s3_bucket" "site_bucket" {
    bucket = "${var.site_bucket_name}.com"
    acl = "public-read"
    website {
        index_document = "index.html"
        error_document = "error.html"
    }
}

resource "aws_s3_bucket" "www_site_bucket" {
    bucket = "www.${var.site_bucket_name}.com"

    website {
        redirect_all_requests_to = "${var.site_bucket_name}.com"
    }    
}

resource "aws_s3_bucket_object" "s3_index_object" {
    bucket = "${var.site_bucket_name}.com"
    key = "index.html"
    source = "${path.cwd}/src/index.html"

    etag = "${filemd5("${path.cwd}/src/index.html")}"

    content_type = "text/html"

}

resource "aws_s3_bucket_object" "s3_error_object" {
    bucket = "${var.site_bucket_name}.com"
    key = "error.html"
    source = "${path.cwd}/src/error.html"

    etag = "${filemd5("${path.cwd}/src/error.html")}"

    content_type = "text/html"
}


resource "aws_s3_bucket_policy" "site_bucket_policy" {
    bucket = "${aws_s3_bucket.site_bucket.id}"
    policy = "${data.aws_iam_policy_document.site_bucket_policy.json}"
}

data "aws_iam_policy_document" "site_bucket_policy" {
    statement {
        sid = "PublicReadGetObject"
        principals {
            type = "AWS"
            identifiers = [ "*" ]
        }
        effect = "Allow"
        actions = [
            "s3:GetObject"
        ]
        resources = [
            "arn:aws:s3:::${var.site_bucket_name}.com/*"
        ]
    }
}

# ROUTE53 (DNS) STUFF
data "aws_route53_zone" "main_zone_instance" {
    name = "${var.hosted_zone_name}."
}

resource "aws_route53_record" "record_instance" {
    zone_id = "${data.aws_route53_zone.main_zone_instance.zone_id}"
    name = "${var.site_bucket_name}.com"
    type = "A"

    alias {
        name = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
        zone_id = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "www_record_instance" {
    zone_id = "${data.aws_route53_zone.main_zone_instance.zone_id}"
    name = "www.${var.site_bucket_name}.com"
    type = "A"

    alias {
        name = "${aws_route53_record.record_instance.name}"
        zone_id = "${data.aws_route53_zone.main_zone_instance.zone_id}"
        evaluate_target_health = true
    }
}


# HTTPS STUFF
data "aws_ssm_parameter" "certificate" {
    name = "${var.ssm_parameter_name}"
    with_decryption = true
}

# CLOUDFRONT STUFF

resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name = "${aws_s3_bucket.site_bucket.bucket_domain_name}"
        origin_id = "${var.site_bucket_name}-origin"

        s3_origin_config {
            origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
        }
    }

    price_class = "PriceClass_100"

    aliases = [ 
        "${var.hosted_zone_name}", 
        "www.${var.hosted_zone_name}"
    ]

    default_cache_behavior {
        allowed_methods = [ "GET", "HEAD" ]
        cached_methods = [ "GET", "HEAD" ]

        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
        target_origin_id = "${var.site_bucket_name}-origin"

        viewer_protocol_policy = "redirect-to-https"
    }
    restrictions {
        geo_restriction {
            restriction_type = "whitelist"
            locations = [ "US" ]
        }
    }

    viewer_certificate {
        acm_certificate_arn = "${data.aws_ssm_parameter.certificate.value}"
        minimum_protocol_version = "TLSv1.1_2016"
        ssl_support_method = "sni-only"
    }

    enabled = true
    default_root_object = "index.html"

    http_version = "http2"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "The CloudFront Origin Access Identity for the S3 Origin Config"
}

data "aws_iam_policy_document" "s3_cloudfront_policy" {
    statement {
        actions = [ "s3:GetObject" ]
        resources = [ "${aws_s3_bucket.site_bucket.arn}/*"]

        principals {
            type = "AWS"
            identifiers = [ "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
        }
    }

    statement {
        actions = [ "s3:ListBucket" ]
        resources = [ "${aws_s3_bucket.site_bucket.arn}" ]

        principals {
            type = "AWS"
            identifiers = [ "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}" ]
        }
    }
}

resource "aws_s3_bucket_policy" "s3_cloudfront_bucket_policy" {
    bucket = "${aws_s3_bucket.site_bucket.id}"
    policy = "${data.aws_iam_policy_document.s3_cloudfront_policy.json}"
}