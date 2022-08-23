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
            destination: https://${destination_ip}:8091/mnt/point/data-ingress"
      deleteOnSend: true
      errorFolder: /data-ingress/error/warehouse
      filenameRegex: .*
      maxThreadPoolSize: 3
      name: ch_integration
      source: /mnt/send-point
      threadPoolSize: 3
