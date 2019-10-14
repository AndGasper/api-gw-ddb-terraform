output "dev_invoke_url" {
    value = "${module.api.dev_invoke_url}"
    description = "API Gateway Dev Stage URL"
}

output "prod_invoke_url" {
    value = "${module.api.prod_invoke_url}"
    description = "API Gateway Prod Stage URL"
}