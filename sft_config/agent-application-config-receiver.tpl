receiver:
  routes:
    - name: app
      actions:
        - name: renameFile
          properties:
            rename_regex: "${source_filename}"
            rename_replacement: FILENAME
        - name: writeFile
          properties:
            destination: ${destination}
