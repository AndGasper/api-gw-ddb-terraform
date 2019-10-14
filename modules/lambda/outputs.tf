output "lambda_arn" {
    value = "${aws_lambda_function.lambda.arn}"   
    description = "Lambda ARN"
}

output "lambda_s3_hash" {
    value = "${data.aws_s3_bucket_object.lambda_dist_hash.id}"
}

output "lambda_invoke_arn" {
    value = "${aws_lambda_function.lambda.invoke_arn}"
    description = "Lambda Invoke ARN"
}