variable "s3_bucket_for_code" {
    description = "The s3 bucket that has the code for the lambda"
    default = "api-mk-iii"
}

variable "project" {
    description = "The project name"
    default = "a-project-name"
}

variable "region" {
    type = "string"
    description = "The region to deploy stuff to"
    default = "us-east-1"
}