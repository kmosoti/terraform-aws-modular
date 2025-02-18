aws dynamodb create-table `
    --table-name terraform-lock-table `
    --attribute-definitions AttributeName=LockID,AttributeType=S `
    --key-schema AttributeName=LockID,KeyType=HASH `
    --billing-mode PAY_PER_REQUEST `
    --region us-east-1 `
    --profile kzkenlabs-iamadmin-dev