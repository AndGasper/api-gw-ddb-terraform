variable "stage_name" {
    description = "The API Gateway Deployment stage name." 
}

variable "project" {
    description = "The name of the project"
}

variable "s3_bucket" {
    description = "The name of the s3 bucket"
}

variable "s3_key" {
    description = "The name of the S3 object key"
}

variable "lambda_function_name" {
    description = "The name of the lambda function"
}

variable "lambda_handler" {
    description = "Name of the lambda function, e.g. exports test"
}

variable "lambda_runtime" {
    description = "The language runtime"
}

variable "lambda_memory" {
    description = "The amount of memory to 'give' the lambda"
    default = "128"
}


variable "lambda_zip_path" {
    description = "The path to the zip file version of the lambda"
}

variable "region" {
    type = "string"
    description = "The region to deploy stuff to"
    default = "us-east-1"
}
