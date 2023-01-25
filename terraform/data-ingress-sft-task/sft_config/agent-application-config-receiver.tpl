receiver:
  routes:
    - name: internal/AWSDataworx1/inbound/GFTS/CH
      actions:
        - name: renameFile
          properties:
            rename_regex: (.+)
            rename_replacement: FILENAME
        - name: writeFile
          properties:
            destination: ${destination}
