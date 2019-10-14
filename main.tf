terraform {
    required_version = "0.12.5"   
}



module "api" {
    source = "./modules/api-gw-lambda-ddb"
    stage_name = "dev"
    lambda_runtime = "nodejs8.10"
    lambda_handler = "index.handler"
    lambda_function_name = "index"
    lambda_memory = "128"
    lambda_zip_path = "${path.cwd}/app-src/index.zip"

    s3_bucket = "${var.s3_bucket_for_code}"
    s3_key = "main"

    project = "${var.project}"
}