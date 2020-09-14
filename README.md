# Appcircle File Upload to Amazon S3

This step uploads a file to Amazon S3. 

Required Input Variables
- `$AWS_ACCESS_KEY_ID`: AWS access key id
- `$AWS_SECRET_ACCESS_KEY`: AWS secret access key (Visit [AWS access keys documentation](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) for details)
- `$AWS_BUCKET_NAME`: AWS bucket name
- `$AC_INPUT_FILE_PATH`: Path to the file to be uploaded

Optional Input Variables
- `$AWS_BUCKET_REGION`: AWS bucket region. Defaults to `us-east-1`
