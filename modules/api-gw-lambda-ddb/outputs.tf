
output "dev_invoke_url" {
    value = "${aws_api_gateway_deployment.api_gateway_deployment_dev.invoke_url}"
    description = "API Gateway Dev Stage URL"
}

output "prod_invoke_url" {
    value = "${aws_api_gateway_deployment.api_gateway_deployment_prod.invoke_url}"
    description = "API Gateway Prod Stage URL"
}