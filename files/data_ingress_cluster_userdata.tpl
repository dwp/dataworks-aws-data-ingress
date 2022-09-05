#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
export AWS_DEFAULT_REGION=${region}
mkdir ${folder}
/usr/bin/s3fs -o iam_role=${instance_role} -o url=https://s3-${region}.amazonaws.com -o endpoint=${region} -o dbglevel=info -o curldbg -o allow_other -o use_cache=/tmp -o umask=0007,uid=65534,gid=65533 ${mnt_bucket} ${folder}

#install deep security agent

tenant_id_activation=$(aws secretsmanager get-secret-value --secret-id ${secret_name} --query SecretString --output text | jq .tenant_id_activation | tr -d '"')
token=$(aws secretsmanager get-secret-value --secret-id ${secret_name} --query SecretString --output text | jq .token | tr -d '"')
policy_id=$(aws secretsmanager get-secret-value --secret-id ${secret_name} --query SecretString --output text | jq .policy_id | tr -d '"')
tenant_id_download=$(aws secretsmanager get-secret-value --secret-id ${secret_name} --query SecretString --output text | jq .tenant_id_download | tr -d '"')
PROXY_ADDR_PORT='${proxy_host}:${proxy_port}/'
RELAY_PROXY_ADDR_PORT='${proxy_host}:${proxy_port}/'
touch /etc/use_dsa_with_iptables
curl --proxy http://${proxy_host}:${proxy_port} https://app.deepsecurity.trendmicro.com:443/software/agent/amzn2/x86_64/agent.rpm?tenantID=$tenant_id_download -o /tmp/agent.rpm --silent --tlsv1.2
if [[ -s /tmp/agent.rpm ]]; then
    rpm -ihv /tmp/agent.rpm
fi
sleep 7
/opt/ds_agent/dsa_control -x dsm_proxy://$PROXY_ADDR_PORT/
/opt/ds_agent/dsa_control -y relay_proxy://$RELAY_PROXY_ADDR_PORT/
/opt/ds_agent/dsa_control -a dsm://agents.deepsecurity.trendmicro.com:443/ "tenantID:$tenant_id_activation" "token:$token" "policyid:$policy_id"

export INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
UUID=$(dbus-uuidgen | cut -c 1-8)
export HOSTNAME=${name}-$UUID
hostnamectl set-hostname $HOSTNAME
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$HOSTNAME
