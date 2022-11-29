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

    - name: app-route-test
      actions:
        - name: renameFile
          properties:
            rename_regex: "${source_filename}"
            rename_replacement: FILENAME
        - name: writeFile
          properties:
            destination: ${destination_route_test}