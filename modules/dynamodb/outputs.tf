output "dynamodb_table_arn" {
    value = "${aws_dynamodb_table.ddb_table.arn}"
}