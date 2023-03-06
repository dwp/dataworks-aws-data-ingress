import logging
import os
import boto3
import sys


def setup_logging(log_path=None):
    json_format = "{ \"timestamp\": \"%(asctime)s\", \"log_level\": \"%(levelname)s\", \"message\": \"%(message)s\"}"
    log_level = os.environ["LOG_LEVEL"].upper() if "LOG_LEVEL" in os.environ else "INFO"
    the_logger = logging.getLogger()
    for old_handler in the_logger.handlers:
        the_logger.removeHandler(old_handler)
    if log_path is None:
        handler = logging.StreamHandler(sys.stdout)
    else:
        handler = logging.FileHandler(log_path)
        handler.setFormatter(logging.Formatter(json_format))
        the_logger.addHandler(handler)
        new_level = logging.getLevelName(log_level.upper())
        the_logger.setLevel(new_level)
    return the_logger


log_path = os.getenv('log_path')
logger = setup_logging(log_path)


def enable(alarm_name):
    try:
        enable_alarm = client.enable_alarm_actions(AlarmNames=[alarm_name])
        return enable_alarm
    except Exception as e:
        logger.error(f'Failed to enable ararm {alarm_name}. {e}')


def disable(alarm_name):
    try:
        disable_alarm = client.disable_alarm_actions(AlarmNames=[alarm_name])
        return disable_alarm
    except Exception as e:
        logger.error(f'Failed to disable ararm {alarm_name}. {e}')


def lambda_handler(event, context):

    global client
    client = boto3.client('cloudwatch')

    global action
    action = os.getenv('action')

    global alarm_names
    alarm_name = os.getenv('alarm_name')

    if action == "enable":
        enable(alarm_name)
    if action == "disable":
        disable(alarm_name)