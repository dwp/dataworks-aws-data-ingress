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
1. [data-ingress-scaling](https://github.com/dwp/dataworks-aws-data-ingress/tree/master/terraform/data-ingress-scaling): contains autoscaling schedules, 

## Tests

Feature name: [@data-ingress](https://github.com/dwp/dataworks-behavioural-framework/blob/master/src/features/data-ingress.feature).

### Scaling tests
The scaling of the autoscaling group is carried out by using `aws_autoscaling_schedule` terraform resources.

Two monthly actions, scale up to 1 and scale down to 0, are expected in the production environment. The recurrence of these is `00 23 1 * *` and `00 23 4 * *` respectively.

Additionally, two time-based actions are triggered whenever a Pull request is merged. The recurrence of these schedules is `current time + 5m` for upscaling to 2 (1+1 instance for hosting the SFT sender that is only used for testing) and `current time + 18m` for downscaling to 0. After the test has completed, the schedules are removed.


### Trend micro test

When the following conditions are true
```
ENVIRONMENT == 'development'
TESTING_ON == 'ci'
TYPE == 'receiver'
```
the Trend Micro test runs and an Eicar test file is created, detected and removed and a notification is sent to Trend Micro dashboard.

### SFT test

The sender agent will create a file in the mount point directory that is then sent to the receiver endpoint that renames it and puts it on S3. Example configuration for the receiver including testing routs are defined in the [e2e congif](https://github.com/dwp/dataworks-aws-data-ingress/blob/master/terraform/data-ingress-sft-task/sft_config/agent-application-config-receiver-e2e.tpl).


