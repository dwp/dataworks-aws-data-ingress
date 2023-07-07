receiver:
  routes:
    - name: internal/AWSDataworx1/inbound/GFTS/CH
      actions:
        - name: renameFile
          properties:
            rename_regex: (.+)
            rename_replacement: ${filename_prefix}-NOW[yyyy-MM-dd].zip
        - name: writeFile
          properties:
            destination: ${destination}
