{
  "cpu": ${cpu},
  "image": "${image_url}",
  "memory": ${memory},
  "memoryReservation": ${memory_reservation},
  "volumesFrom": [],
  "name": "${name}",
  "networkMode": "host",
  "user": "${user}",
  "essential": ${essential},
  "privileged": ${privileged},
  "containerName": "${name}",
  "ulimits": ${jsonencode([
    for limit in jsondecode(ulimits) :
    {
      name      = "nofile",
      hardLimit = limit,
      softLimit = limit
    }
  ])},
  "healthCheck": {
    "command": [
      "CMD-SHELL",
      "pgrep -f sft-agent.jar"
    ],
    "interval": 5,
    "timeout": 2,
    "retries": 10,
    "startPeriod": 300
  },
  "mountPoints": ${jsonencode([
    for mount in jsondecode(mount_points) : {
      containerPath = mount.container_path,
      sourceVolume = mount.source_volume
    }
  ])},
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "${log_group}",
      "awslogs-region": "${region}",
      "awslogs-stream-prefix": "${name}"
    }
  },
  "environment": ${jsonencode(concat([
      {
        "name": join("", [upper(group_name), "_CONFIG_S3_BUCKET"]),
        "value": config_bucket
      },
      {
        "name": join("", [upper(group_name), "_CONFIG_S3_PREFIX"]),
        "value": s3_prefix
      }
    ],
    [
      for variable in jsondecode(environment_variables) : {
        name = variable.name,
        value = variable.value
      }
    ]
  ))}
}
