receiver:
  routes:
    - name: internal/AWSDataworx1/inbound/GFTS/CH
      actions:
        - name: renameFile
          properties:
            rename_regex: (.+)
            rename_replacement: ${filename_prefix}-NOW[yyyy-MM-dd].zip
        - name: writeFile
          properties:
            destination: ${destination}
%{ if test_sft ~}
    - name: DA
      actions: 
        - name: writeFile
          properties:
            destination: /mnt/point/e2e/data-egress/startup-test
%{ endif }