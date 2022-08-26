receiver:
  routes:
    - name: app
      actions:
        - name: renameFile
          properties:
            rename_regex: prod217.csv
            rename_replacement: FILENAME
        - name: writeFile
          properties:
            destination: /mnt/point/data-ingress
