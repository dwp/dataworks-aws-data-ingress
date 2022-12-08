# DataWorks AWS Data Ingress

## A repository for Data Ingress ECS cluster infrastructure

This repository contains Makefile and base terraform folders and jinja2 files to fit the standard pattern.

Running `aviator` will create the pipeline required on the AWS-Concourse instance, in order pass a mandatory CI ran status check.  this will likely require you to login to Concourse, if you haven't already.

After cloning this repo, please generate `terraform.tf` and `terraform.tfvars` files:  
`make bootstrap`

In addition, you may want to do the following: 

1. Create non-default Terraform workspaces as and if required:  
    `make terraform-workspace-new workspace=<workspace_name>` e.g.  
    ```make terraform-workspace-new workspace=qa```

1. Configure Concourse CI pipeline:
    1. Add/remove jobs in `./ci/jobs` as required 
    1. Create CI pipeline:  
`aviator`


## ECS Cluster 

Data Ingress ECS cluster sits in the sdx VPC.

Trend Micro deep security agent is installed via user data on the EC2 instances. Installation details such as tenant id and token are stored in dataworks-secrets.

Sft agent task runs the [ingress sft agent image](https://github.com/dwp/dataworks-ingress_sft-agent) that imports, scans and uploads files to the data ingress stage bucket.


## Terraform modules

1. [data-ingress-cluster](https://github.com/dwp/dataworks-aws-data-ingress/tree/master/terraform/data-ingress-cluster): contains resources needed to create ECS cluster including launch template, autoscaling group and monitoring.
1. [data-ingress-sft-task](https://github.com/dwp/dataworks-aws-data-ingress/tree/master/terraform/data-ingress-sft-task): contains SFT ingress tasks and services.
1. [data-ingress-scaling](https://github.com/dwp/dataworks-aws-data-ingress/tree/master/terraform/data-ingress-scaling): contains autoscaling schedules, two monthly actions and two time-based actions used for testing (feature name: [@data-ingress](https://github.com/dwp/dataworks-behavioural-framework/blob/master/src/features/data-ingress.feature)).

