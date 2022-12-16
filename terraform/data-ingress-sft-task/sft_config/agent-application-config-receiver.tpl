receiver:
  routes:
    - name: internal/AWSDataworx1/inbound/GFTS/CH
      actions:
        - name: renameFile
          properties:
            rename_regex: "${source_filename}"
            rename_replacement: FILENAME
        - name: writeFile
          properties:
            destination: ${destination_route_test}

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
