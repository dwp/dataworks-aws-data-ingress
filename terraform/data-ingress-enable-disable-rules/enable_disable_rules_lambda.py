import logging
import os
import boto3
import sys


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


def enable_rule(rule_name):
    try:
        logger.info(f'Enabling rule {rule_name}.')
        enable_rule = events_client.enable_rule(Name=rule_name)
        return enable_rule
    except Exception as e:
        logger.error(f'Failed to enable rule {rule_name}. {e}')


def disable_rule(rule_name):
    try:
        logger.info(f'Disabling rule {rule_name}.')
        disable_rule = events_client.disable_rule(ruleNames=rule_name)
        return disable_rule
    except Exception as e:
        logger.error(f'Failed to disable rule {rule_name}. {e}')


def disable_alarm(alarm_name):
    try:
        logger.info(f"Disabling alarm {alarm_name}")
        cw_client.disable_alarm_actions(AlarmNames=[alarm_name])
    except Exception as e:
        logger.error(f'Failed to disable alarm {alarm_name}. {e}')


def enable_alarm(alarm_name):
    try:
        logger.info(f"Enabling alarm {alarm_name}")
        cw_client.enable_alarm_actions(AlarmNames=[alarm_name])
    except Exception as e:
        logger.error(f'Failed to enable alarm {alarm_name}. {e}')


def alarm_ok(alarm_name):
    cw_client.set_alarm_state(
        AlarmName=alarm_name,
        StateValue='OK'
    )


def lambda_handler(event, context):

    global events_client
    events_client = boto3.client('events')

    global cw_client
    cw_client = boto3.client('cloudwatch')

    action = os.getenv('action')
    rule_name = os.getenv('rule_name')
    alarm_name = os.getenv('alarm_name')

    if action == "enable":
        enable_rule(rule_name)
        enable_alarm(alarm_name)
        alarm_ok(alarm_name)

    if action == "disable":
        disable_rule(rule_name)
        disable_alarm()