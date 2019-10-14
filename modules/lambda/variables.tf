variable "function_name" {
    description = "The name of the lambda function"
}

variable "runtime" {
    description = "The runtime of the lambda to create"
}

variable "s3_bucket" {
    description = "The name of the S3 Bucket with the lambda code"
}

variable "s3_key" {
    description = "The filename of the lambda zip in the s3 bucket"
}

variable "handler" {
    description = "The name of the lambda function for the handler"
}

variable "name_you_want_for_s3" {
    description = "The name you want for the object key"
}


variable "memory" {
    description = "The memory sized of the lambda function"
}

variable "role" {
    description = "The IAM role attached to the Lambda function (ARN)"
}

variable "lambda_zip_path" {
    description = "The path to the lambda entrypoint"
}


variable "region" {
    description = "The region to deploy the lambda to"
}


variable "lambda_logging_name" {
    description = "The name of the cloudwatch logs for lambda to log to"
}
