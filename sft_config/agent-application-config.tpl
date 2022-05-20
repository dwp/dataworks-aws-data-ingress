receiver:
  routes:
    - name: route1
      actions:
        - name: writeFile
          properties:
            destination: ./tmp/
      actions:
        - name: renameFile
          properties:
           rename_regex: (.*)(.csv)
           rename_replacement: $1today$2