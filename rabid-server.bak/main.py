"""
Main file of the UDP Hole Puncher Server
You can activate debug mode by calling the main method with 'DEBUG' as the second parameter
"""
import sys
import logging
import logger
from twisted.internet import reactor
from server import Server


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: ./main.py <port>")
        print("Run with debug: ./main.py <port> DEBUG")
        sys.exit(1)

    if len(sys.argv) > 2 and sys.argv[2] == "DEBUG":
        print("+-+-+-+ Debug mode activated +-+-+-+")
        logger.LOG_LEVEL = logging.DEBUG

    port = int(sys.argv[1])
    reactor.listenUDP(port, Server())
    logger.get_logger("Main").info('Listening on *:%d' % port)
    reactor.run()
