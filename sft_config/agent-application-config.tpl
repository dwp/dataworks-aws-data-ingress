receiver:
  routes:
    - name: ch_integration
      actions:
        - name: renameFile
          properties:
            rename_regex: (.*.csv)
            rename_replacement: "BasicCompanyData\-${today}\.csv"
        - name: writeFile
          properties:
            destination: /mnt/point/data-ingress
