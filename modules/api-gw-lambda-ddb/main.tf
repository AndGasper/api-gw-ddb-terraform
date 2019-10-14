resource "aws_api_gateway_rest_api" "api_gateway" {
    name = "ApiGateway-mk-iii"
    description = "A REST API Gateway"
}
# Enable Proxy Behavior - _this kills the composition crab_
resource "aws_api_gateway_resource" "proxy" {
    rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
    parent_id = "${aws_api_gateway_rest_api.api_gateway.root_resource_id}"
    path_part = "{proxy+}"    
}

resource "aws_api_gateway_method" "proxy" {
    rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
    resource_id = "${aws_api_gateway_resource.proxy.id}"
    http_method = "ANY"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
    rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
    resource_id = "${aws_api_gateway_method.proxy.resource_id}"
    http_method =  "${aws_api_gateway_method.proxy.http_method}"

    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = "${module.lambda.lambda_invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
    rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
    resource_id = "${aws_api_gateway_rest_api.api_gateway.root_resource_id}"
    http_method = "ANY"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
    rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
    resource_id = "${aws_api_gateway_rest_api.api_gateway.root_resource_id}"
    http_method = "${aws_api_gateway_method.proxy_root.http_method}"

    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = "${module.lambda.lambda_invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_deployment_dev" {
    depends_on = [
        "aws_api_gateway_integration.lambda",
        "aws_api_gateway_integration.lambda_root"
    ]
    rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
    stage_name = "dev"
}

resource "aws_api_gateway_deployment" "api_gateway_deployment_prod" {
    depends_on = [
        "aws_api_gateway_integration.lambda",
        "aws_api_gateway_integration.lambda_root"
    ]
    rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
    stage_name = "prod"
}

# So I can use account id in the source_arn
data "aws_caller_identity" "current" {}

# API Gateway -invoke-> Lambda
resource "aws_lambda_permission" "api_gateway_invoke_lambda" {
    statement_id = "AllowExecutionFromApiGateway"
    action = "lambda:InvokeFunction"
    function_name = "${var.project}-${var.stage_name}-${var.lambda_function_name}"
    principal = "apigateway.amazonaws.com"
       
    source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/*"
}


# API Gateway Settings
resource "aws_api_gateway_method_settings" "api_gateway_settings" {
    rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
    depends_on = [
        "aws_api_gateway_deployment.api_gateway_deployment_dev"
    ]
    stage_name = "${var.stage_name}"
    # {resourcePath}/{httpMethod} => doesn't support ANY?
    # Since I'm using a proxy
    method_path = "*/*"

    settings {
        metrics_enabled = true
        logging_level = "INFO"
    }
}

# LAMBDA STUFF
module "lambda" {
    source = "../lambda"
    s3_bucket = "${var.s3_bucket}-${var.project}"
    s3_key = "${var.s3_key}"
    function_name = "${var.project}-${var.stage_name}-${var.lambda_function_name}"
    handler = "${var.lambda_handler}"
    runtime = "${var.lambda_runtime}"
    role = "${aws_iam_role.lambda_role}"
    memory = "${var.lambda_memory}"
    lambda_zip_path = "${var.lambda_zip_path}"
    region = "${var.region}"

    name_you_want_for_s3 = "index.zip"

    lambda_logging_name = "/aws/logs/${var.project}-lambda-logs-${var.stage_name}"
} 


resource "aws_iam_role" "lambda_role" {
    assume_role_policy = "${data.aws_iam_policy_document.lambda_policies.json}"
}

resource "aws_iam_role_policy" "ddb_read_role_policy" {
    role = "${aws_iam_role.lambda_role.id}"
    policy = "${data.template_file.read_ddb_table_policy_template.rendered}"
}


data "template_file" "read_ddb_table_policy_template" {
    template = "${file("${path.cwd}/templates/read-ddb-policy.json.tpl")}"
    vars = {
        resource = "${module.dynamodb.dynamodb_table_arn}"
    }
}

data "aws_iam_policy_document" "lambda_policies" {
    # Assume role
    statement {
        effect = "Allow"
        actions = [ "sts:AssumeRole" ]

        principals {
            type = "Service"
            identifiers = [ "lambda.amazonaws.com" ]
        }
    }
}
# DynamoDB
module "dynamodb" {
    source = "../dynamodb"
    ddb_table_name = "${var.project}-${var.stage_name}"
}


# CLOUDWATCH: Log API Gateway 
resource "aws_api_gateway_account" "api_gateway_account" {
    # Because there might not be any apigateway "stuff" on an account
    depends_on = [
        "aws_api_gateway_account.api_gateway_account"
    ]
    cloudwatch_role_arn = "${aws_iam_role.api_gateway_log_to_cloudwatch_role.arn}"

}

resource "aws_cloudwatch_log_group" "cloudwatch_log" {
    name = "/aws/logs/cloudwatch-log-group-${var.project}-${var.stage_name}" 
    retention_in_days = 30
    tags = {
        environment = "${var.stage_name}" 
    }
}

resource "aws_iam_role" "api_gateway_log_to_cloudwatch_role" {   
    assume_role_policy = "${data.aws_iam_policy_document.api_gateway_log_to_cloudwatch_policies.json}"

}
data "aws_iam_policy_document" "api_gateway_log_to_cloudwatch_policies" {
    statement {
        effect = "Allow"
        actions = [ "sts:AssumeRole" ]

        principals {
            type = "Service"
            identifiers = [ "apigateway.amazonaws.com" ]
        } 
    }
}

resource "aws_iam_role_policy" "cloudwatch_logging_role_policy" {
    policy = "${data.template_file.cloudwatch_log_policy_template.rendered}"
    # The role to attach the policy to
    role = "${aws_iam_role.api_gateway_log_to_cloudwatch_role.id}"
}

# Template file for cloudwatch logs
data "template_file" "cloudwatch_log_policy_template" {
    template = "${file("${path.cwd}/templates/cloudwatch-log-policy.json.tpl")}"
    vars = {
        resource = "${aws_cloudwatch_log_group.cloudwatch_log.arn}"
    }
}
