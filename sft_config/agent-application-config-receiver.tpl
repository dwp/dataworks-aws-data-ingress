receiver:
  routes:
    - name: ch_integration
      actions:
        - name: writeFile
          properties:
            destination: ${destination}
