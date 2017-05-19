import os
import logging
import sys
import common.config.config  as config

class Logger(object):

    def __init__(self, name):
        name = name.replace('.log','')
        logger = logging.getLogger('(%s)' % name)    # log_namespace can be replaced with your namespace
        logger.setLevel(logging.DEBUG)
        formatter = logging.Formatter('%(asctime)s %(levelname)s:%(name)s %(message)s')
        if not logger.handlers:
            if not os.path.exists(config.logging_dir):
                os.mkdir(config.logging_dir, 0o755)
            file_name = os.path.join(config.logging_dir, '%s.log' % name)
            handler = logging.FileHandler(file_name)
            handler.setFormatter(formatter)
            logger.addHandler(handler)
        if config.logging_stdout:
            stdHanddler = logging.StreamHandler(sys.stdout)
            stdHanddler.setFormatter(formatter)
            logger.addHandler(stdHanddler)
        self._logger = logger

    def get(self):
        return self._logger