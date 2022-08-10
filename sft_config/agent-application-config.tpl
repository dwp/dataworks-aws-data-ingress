receiver:
  routes:
    - name: ch_integration
      actions:
        - name: renameFile
          properties:
            rename_regex: prod217.csv
            rename_replacement: "${filename_prefix}\-${today}\.csv"
        - name: writeFile
          properties:
            destination: /mnt/point/data-ingress
