#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
export AWS_DEFAULT_REGION=${region}
mkdir ${folder}
/usr/bin/s3fs -o iam_role=${instance_role} -o url=https://s3-${region}.amazonaws.com -o endpoint=${region} -o dbglevel=info -o curldbg -o allow_other -o use_cache=/tmp -o umask=0007,uid=65534,gid=65533 ${mnt_bucket} ${folder}

#install deep security agent

# Add VPC IP's to local host file with local DNS config for Trend
echo Adding VPC Endpoint IP to hosts file
vpce_ip1=$(dig +short "${proxy_host}" | sed -n 1p | grep '^[.0-9]*$')
sed -i -e '$a'"$vpce_ip1"'  'dwx-squid-proxy.local /etc/hosts

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
sleep 15
/opt/ds_agent/dsa_control -x dsm_proxy://$PROXY_ADDR_PORT/
/opt/ds_agent/dsa_control -y relay_proxy://$RELAY_PROXY_ADDR_PORT/
/opt/ds_agent/dsa_control -a dsm://agents.deepsecurity.trendmicro.com:443/ "tenantID:$tenant_id_activation" "token:$token" "policyid:$policy_id"

export INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
UUID=$(dbus-uuidgen | cut -c 1-8)
export HOSTNAME=${name}-$UUID
hostnamectl set-hostname $HOSTNAME
sleep 20
state=$(/opt/ds_agent/dsa_query -c "GetAgentStatus"|grep AgentStatus.auStatus)

if [ "$state" = "AgentStatus.auStatus: 2" ]; then
    echo trend micro is active
else
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID
fi
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$HOSTNAME


echo "Creating directories"
mkdir -p /var/log/ingress
mkdir -p /opt/ingress


echo "Downloading startup scripts"
S3_LOGROTATE="s3://${s3_scripts_bucket}/${s3_script_logrotate}"
S3_CLOUDWATCH_SHELL="s3://${s3_scripts_bucket}/${s3_script_cloudwatch_shell}"
S3_LOGGING_SHELL="s3://${s3_scripts_bucket}/${s3_script_logging_shell}"
S3_CONFIG_HCS_SHELL="s3://${s3_scripts_bucket}/${s3_script_config_hcs_shell}"

echo "Copying scripts"
$(which aws) s3 cp "$S3_LOGROTATE"     /etc/logrotate.d/dks/dks.logrotate
$(which aws) s3 cp "$S3_CLOUDWATCH_SHELL"  /opt/ingress/cloudwatch.sh
$(which aws) s3 cp "$S3_LOGGING_SHELL"     /opt/ingress/logging.sh
$(which aws) s3 cp "$S3_CONFIG_HCS_SHELL"  /opt/ingress/config_hcs.sh

echo "Setup cloudwatch logs"
chmod u+x /opt/ingress/cloudwatch.sh
/opt/ingress/cloudwatch.sh \
    "${cwa_metrics_collection_interval}" "${cwa_namespace}" "${cwa_cpu_metrics_collection_interval}" \
    "${cwa_disk_measurement_metrics_collection_interval}" "${cwa_disk_io_metrics_collection_interval}" \
    "${cwa_mem_metrics_collection_interval}" "${cwa_netstat_metrics_collection_interval}" "${cwa_log_group_name}" \
    "$AWS_DEFAULT_REGION"

echo "Setup hcs pre-requisites"
chmod u+x /opt/ingress/config_hcs.sh
/opt/ingress/config_hcs.sh "${hcs_environment}" "${proxy_host}" "${proxy_port}" "${tanium_server_1}" "${tanium_server_2}" "${tanium_env}" "${tanium_port}" "${tanium_log_level}" "${install_tenable}" "${install_trend}" "${install_tanium}" "${tenantid}" "${token}" "${policyid}" "${tenant}"

echo "Creating ingress user"
useradd ingress -m

echo "Changing permissions"
chown ingress:ingress -R  /opt/ingress
chown ingress:ingress -R  /var/log/ingress
