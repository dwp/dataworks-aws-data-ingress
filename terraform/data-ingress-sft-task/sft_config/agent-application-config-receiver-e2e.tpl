receiver:
  routes:
    - name: internal/AWSDataworx1/inbound/GFTS/CH
      actions:
        - name: renameFile
          properties:
            rename_regex: ".*"
            rename_replacement: "testname.csv"
        - name: writeFile
          properties:
            destination: ${destination_e2e}
