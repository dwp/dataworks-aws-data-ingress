#cloud-boothook
#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_AWSVPC_BLOCK_IMDS=true >> /etc/ecs/ecs.config
mkdir ${folder}
/usr/bin/s3fs -o iam_role=${instance_role} -o url=https://s3-${region}.amazonaws.com -o endpoint=${region} -o dbglevel=info -o curldbg -o allow_other -o use_cache=/tmp -o umask=0007,uid=65534,gid=65533 ${mnt_bucket} ${folder}
export AWS_DEFAULT_REGION=${region}
export INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
UUID=$(dbus-uuidgen | cut -c 1-8)
export HOSTNAME=${name}-$UUID
hostnamectl set-hostname $HOSTNAME
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$HOSTNAME
