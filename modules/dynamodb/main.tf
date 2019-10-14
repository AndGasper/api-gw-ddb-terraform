resource "aws_dynamodb_table" "ddb_table" {
    name = "${var.ddb_table_name}"
    billing_mode = "PROVISIONED"
    read_capacity = 20
    write_capacity = 20
    hash_key = "id"

    attribute {
        name = "id"
        type = "S"
    }
    # Should a module be "allowed" to define its own tags?
    tags = {
        resource-name = "${var.ddb_table_name}"
    }
}
