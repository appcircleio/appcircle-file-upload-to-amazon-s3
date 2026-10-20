# Appcircle Upload Files to Amazon S3

This step uploads a file to Amazon S3. 

Required Input Variables
- `$AWS_ACCESS_KEY_ID`: Amazon S3 access key id
- `$AWS_SECRET_ACCESS_KEY`: AAmazon S3 secret access key (Visit [AWS access keys documentation](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) for details)
- `$AWS_BUCKET_NAME`: Amazon S3 bucket name
- `$AC_INPUT_FILE_PATH`: Path to the file to be uploaded

Optional Input Variables
- `$AWS_BUCKET_REGION`: Amazon S3 bucket region, passed to `aws s3 cp` as `--region`. Defaults to `us-east-1`
- `$AWS_TARGET_DIR`: Folder path in the bucket. Defaults to the current UTC timestamp
- `$AWS_ENDPOINT_URL_S3`: Endpoint of an S3-compatible storage such as MinIO, for example `https://minio.example.com:9000`. Leave empty for Amazon S3
- `$AC_AWS_CLI_BASE_URL`: Base URL to download AWS CLI v2 from when `aws` is not installed. Defaults to `https://awscli.amazonaws.com`. In air-gapped environments, point it to a raw proxy of that host in your artifact proxy, for example `https://nexus.example.com/repository/awscli`

If `aws` is already on `PATH`, the download is skipped. On macOS the downloaded package is installed only if it is signed by the AWS CLI publisher (Developer ID Installer, team ID `94KV3E626L`).

AWS CLI uses its own CA bundle, not the macOS keychain. If the S3 endpoint uses a certificate from an internal CA, set `AWS_CA_BUNDLE` to the path of that CA's PEM file in the build environment variables.

Output Variables
- `$AC_AWS_UPLOAD_URL`: Amazon S3 upload url (s3://your-bucket-name/timestamp)
