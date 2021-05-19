# Appcircle Upload Files to Amazon S3

This step uploads a file to Amazon S3. 

Required Input Variables
- `$AWS_ACCESS_KEY_ID`: Amazon S3 access key id
- `$AWS_SECRET_ACCESS_KEY`: AAmazon S3 secret access key (Visit [AWS access keys documentation](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) for details)
- `$AWS_BUCKET_NAME`: Amazon S3 bucket name
- `$AC_INPUT_FILE_PATH`: Path to the file to be uploaded

Optional Input Variables
- `$AWS_BUCKET_REGION`: Amazon S3 bucket region. Defaults to `us-east-1`

Output Variables
- `$AC_AWS_UPLOAD_URL`: Amazon S3 upload url (s3://your-bucket-name/timestamp)
