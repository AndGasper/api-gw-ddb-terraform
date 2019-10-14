{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:Scan"
            ],
            "Effect": "Allow",
            "Resource": "${resource}"
        }
    ]   
}