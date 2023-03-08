import logging
import os
import boto3
import sys
from datetime import datetime


def setup_logging():
    json_format = "{ \"timestamp\": \"%(asctime)s\", \"log_level\": \"%(levelname)s\", \"message\": \"%(message)s\"}"
    log_level = os.environ["LOG_LEVEL"].upper() if "LOG_LEVEL" in os.environ else "INFO"
    the_logger = logging.getLogger()
    for old_handler in the_logger.handlers:
        the_logger.removeHandler(old_handler)
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(logging.Formatter(json_format))
    the_logger.addHandler(handler)
    new_level = logging.getLevelName(log_level.upper())
    the_logger.setLevel(new_level)
    return the_logger


logger = setup_logging()


def s3_keys(bucket, prefix):
    logger.info(f"looking for objects with prefix {prefix}")
    try:
        bkt = s3.Bucket(bucket)
        return bkt.objects.filter(Prefix=prefix)
    except Exception as ex:
        logger.error(f"failed to list keys in bucket. {ex}")


def alarm(alarm_name):
    cw_client.set_alarm_state(
        AlarmName=alarm_name,
        StateValue='ALARM',
        StateReason='no_file_received'
    )


def lambda_handler(event, context):

    global s3
    s3 = boto3.resource('s3')

    global cw_client
    s3_client = boto3.client('cloudwatch')

    bucket = os.getenv('bucket')
    prefix = os.getenv('prefix')
    alarm_name = os.getenv('alarm_name')
    filename_prefix = os.getenv('filename_prefix')+datetime.now().strftime('%Y-%m')
    keys = s3_keys(bucket, prefix)

    if not any([filename_prefix in key for key in keys]):
        logger.info(f"No file like {filename_prefix}* found, triggering alarm")
        alarm(alarm_name)
