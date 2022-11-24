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
            destination: "https://${ip}:${port}/app"
      deleteOnSend: false
      errorFolder: /data-ingress/error/warehouse
      filenameRegex: .*
      maxThreadPoolSize: 5
      name: app
      source: /mnt/send_point/
      threadPoolSize: 5
