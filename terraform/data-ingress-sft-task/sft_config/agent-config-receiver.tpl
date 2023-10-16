server:
  applicationConnectors:
    - type: http
      port: 8091
logging:
  appenders:
    - type: console
      threshold: INFO
      target: stdout
      logFormat: "%d{yyyy-MM-dd HH:mm:ss.SSS} [%30.30t] %-30.30c{1} %mdc{} %-5p %m%n"
    - type: file
      threshold: INFO
      logFormat: "%d{yyyy-MM-dd HH:mm:ss.SSS} [%30.30t] %-30.30c{1} %mdc{} %-5p %m%n"
      currentLogFilename: /var/log/sft/sft-agent.log
      archivedLogFilenamePattern: /var/log/sft-agent-%d.log.gz
      archivedFileCount: 7
      timeZone: UTC
apikey: ${apiKey}
<#include "agent-application-config.yml">
