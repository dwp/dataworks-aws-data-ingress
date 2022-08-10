receiver:
  routes:
    - name: ch_integration
      actions:
        - name: renameFile
          properties:
            rename_regex: prod217.csv
            rename_replacement: ${filename_prefix}
        - name: writeFile
          properties:
            destination: ${destination}
