# dataworks-aws-data-ingress

## A repo for Dataworks AWS Data ingress service infrastructure

This repo contains Makefile and base terraform folders and jinja2 files to fit the standard pattern.
This repo is a base to create new Terraform repos, renaming the template files and adding the githooks submodule, making the repo ready for use.

Running aviator will create the pipeline required on the AWS-Concourse instance, in order pass a mandatory CI ran status check.  this will likely require you to login to Concourse, if you haven't already.

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
