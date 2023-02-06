receiver:
  routes:
    - name: internal/AWSDataworx1/inbound/GFTS/CH
      actions:
        - name: renameFile
          properties:
            rename_regex: (.+.zip)
            rename_replacement: FILENAME
        - name: writeFile
          properties:
            destination: ${destination}
