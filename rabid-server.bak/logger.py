"""
Logger utilities
This file provides some helping config to have a nice logging
mechanism that is easy to use in other parts of the code
By default logs printed with this logger will be output to console
and a rotating log file
"""

import logging
from logging import Logger
from logging.handlers import RotatingFileHandler

LOG_FILE_NAME = "rabid-hole-punch.log"
LOG_MAX_BYTES = 10000000  # 10 MB
LOG_BACKUP_COUNT = 10
LOG_LEVEL = logging.INFO


def get_logger(logger_name: str) -> Logger:
    logger = logging.getLogger(logger_name)
    logger.setLevel(LOG_LEVEL)

    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

    ch = logging.StreamHandler()
    ch.setLevel(LOG_LEVEL)
    ch.setFormatter(formatter)
    logger.addHandler(ch)

    rf = RotatingFileHandler(LOG_FILE_NAME, maxBytes=LOG_MAX_BYTES, backupCount=LOG_BACKUP_COUNT)
    rf.setLevel(LOG_LEVEL)
    rf.setFormatter(formatter)
    logger.addHandler(rf)

    return logger
