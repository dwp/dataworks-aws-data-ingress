
data "local_file" "data_ingress_server_logrotate_script" {
  filename = "files/data_ingress_server.logrotate"
}

resource "aws_s3_object" "data_ingress_server_logrotate_script" {
  bucket  = local.config_bucket.id
  key     = "component/data-ingress-server/data-ingress-server.logrotate"
  content = data.local_file.data_ingress_server_logrotate_script.content

  tags = merge(
    local.common_tags,
    {
      Name = "data-ingress-server-logrotate-script"
    },
  )
}

data "local_file" "data_ingress_server_cloudwatch_script" {
  filename = "files/data_ingress_server_cloudwatch.sh"
}

resource "aws_s3_object" "data_ingress_server_cloudwatch_script" {
  bucket  = local.config_bucket.id
  key     = "component/data-ingress-server/data-ingress-server-cloudwatch.sh"
  content = data.local_file.data_ingress_server_cloudwatch_script.content

  tags = merge(
    local.common_tags,
    {
      Name = "data-ingress-server-cloudwatch-script"
    },
  )
}

data "local_file" "data_ingress_server_logging_script" {
  filename = "files/logging.sh"
}

resource "aws_s3_object" "data_ingress_server_logging_script" {
  bucket  = local.config_bucket.id
  key     = "component/data-ingress-server/data-ingress-server-logging.sh"
  content = data.local_file.data_ingress_server_logging_script.content

  tags = merge(
    local.common_tags,
    {
      Name = "data-ingress-server-logging-script"
    },
  )
}

data "local_file" "data_ingress_server_config_hcs_script" {
  filename = "files/config_hcs.sh"
}

resource "aws_s3_object" "data_ingress_server_config_hcs_script" {
  bucket  = local.config_bucket.id
  key     = "component/data-ingress-server/data-ingress-server-config-hcs.sh"
  content = data.local_file.data_ingress_server_config_hcs_script.content

  tags = merge(
    local.common_tags,
    {
      Name = "data-ingress-server-config-hcs-script"
    },
  )
}
