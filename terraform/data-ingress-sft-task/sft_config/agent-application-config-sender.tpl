sender:
  retryBehaviour:
    backOffMultiplier: 2
    maximumRedeliveries: 3
    maximumRedeliveryDelay: 3600000
    redeliveryDelay: 600000
  routes:
    -
      actions:
        -
          name: httpRequest
          properties:
            destination: "${sft_sender_http_protocol}://${ip}:${port}/internal/AWSDataworx1/inbound/GFTS/CH"
      deleteOnSend: false
      errorFolder: /data-ingress/error/warehouse
      filenameRegex: .*
      maxThreadPoolSize: 5
      name: internal/AWSDataworx1/inbound/GFTS/CH
      source: /mnt/point/
      threadPoolSize: 5
