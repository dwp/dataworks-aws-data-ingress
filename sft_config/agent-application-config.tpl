receiver:
  routes:
    - name: ch_integration
      actions:
        - name: renameFile
          properties:
            rename_regex: prod217.csv
            rename_replacement: prod217.csv
        - name: writeFile
          properties:
            destination: ${destination}
