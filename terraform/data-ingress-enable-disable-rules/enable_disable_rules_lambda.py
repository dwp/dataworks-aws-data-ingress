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


def enable(rule_name):
    try:
        logger.info(f'Enabling rule {rule_name}.')
        enable_rule = client.enable_rule(Name=rule_name)
        return enable_rule
    except Exception as e:
        logger.error(f'Failed to enable rule {rule_name}. {e}')


def disable(rule_name):
    try:
        logger.info(f'Disabling rule {rule_name}.')
        disable_rule = client.disable_rule(ruleNames=rule_name)
        return disable_rule
    except Exception as e:
        logger.error(f'Failed to disable rule {rule_name}. {e}')


def lambda_handler(event, context):

    global client
    client = boto3.client('events')

    global action
    action = os.getenv('action')

    global rule_names
    rule_name = os.getenv('rule_name')

    if action == "enable":
        enable(rule_name)
    if action == "disable":
        disable(rule_name)