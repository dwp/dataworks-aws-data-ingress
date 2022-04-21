sender:
  routes:
    - name: S3verify
      type: s3
      source: ${source_bucket}
      pollDelay: 10000
      maxMessagesPerPoll: 1
      errorFolder: ${error_bucket}
      actions:
        - name: writeFileToS3
        properties:
          destination: ${dest_bucket}
          rootDirectory: ${dest_prefix}
          keyARN: arn:aws:kms:eu-west-2:...
