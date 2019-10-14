resource "aws_lambda_function" "lambda" {
    s3_bucket = "${var.s3_bucket}"
    s3_key = "${var.name_you_want_for_s3}"
    function_name = "${var.function_name}"
    role = "${var.role.arn}"
    handler = "${var.handler}"
    runtime = "${var.runtime}"
    source_code_hash = "${data.aws_s3_bucket_object.lambda_dist_hash.id}"
    memory_size = "${var.memory}"
}

resource "aws_s3_bucket" "lambda_bucket" {
    bucket = "${var.s3_bucket}"
    region = "${var.region}"
}

resource "aws_s3_bucket_public_access_block" "lambda_bucket_access_block" {
    bucket = "${aws_s3_bucket.lambda_bucket.id}"
    # Do not want the world to be able to upload a different acl
    block_public_acls = true
    restrict_public_buckets = true

}

resource "aws_s3_bucket_object" "lambda_dist" {
    bucket = "${aws_s3_bucket.lambda_bucket.bucket}"
    key = "${var.name_you_want_for_s3}"
    source = "${var.lambda_zip_path}"
    etag = "${filebase64sha256(var.lambda_zip_path)}"
}

data "aws_s3_bucket_object" "lambda_dist_hash" {
    bucket = "${aws_s3_bucket.lambda_bucket.bucket}"
    key = "${var.name_you_want_for_s3}"
    # Cannot have a hash without the object => although not sure why this is here?
    depends_on = [ "aws_s3_bucket_object.lambda_dist" ]
}


# Logging stuff
resource "aws_cloudwatch_log_group" "lambda_logs" {
    name = "${var.lambda_logging_name}"
}

resource "aws_iam_policy" "lambda_logging" {
    description = "IAM policy for logging from a lambda"
    policy = "${data.aws_iam_policy_document.lambda_logging_policy.json}"
}
# Define the policy statements
data "aws_iam_policy_document" "lambda_logging_policy" {
    statement {
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        resources = [ "arn:aws:logs:*:*:*" ]
    }
}

# Actually attach the policy to the lambda role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
    role = "${var.role.name}"
    policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}