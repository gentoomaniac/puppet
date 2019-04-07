#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import datetime
import hashlib
import json
import logging
import re
import time
import sys

import click
import pyinotify
from elasticsearch import Elasticsearch

SYSLOG_REGEX = r'^(?P<date>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}\+\d{2}:\d{2})\s(?P<host>\w+)\s(?P<proc>\w+)\[?(?P<pid>\d+)?\]?:\s(?P<message>.*)$'

log = logging.getLogger(__file__)


def _configure_logging(verbosity):
    loglevel = max(3 - verbosity, 0) * 10
    logging.basicConfig(level=loglevel, format='[%(asctime)s] %(levelname)s: %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
    if loglevel >= logging.DEBUG:
        # Disable debugging logging for external libraries
        for loggername in 'urllib3', 'google.auth.transport.requests':
            logging.getLogger(loggername).setLevel(logging.CRITICAL)


def get_es_blob(line: str):
    match = re.match(SYSLOG_REGEX, line)
    if match:
        blob = match.groupdict()
        blob['@timestamp'] = blob['date']
        blob.pop('date')
        return blob

    return None


class EventHandlerDirectory(pyinotify.ProcessEvent):

    def __init__(self, stats, opener, closer, reader, restart_file_inotify, filename):
        """docstring for __init__"""
        super(EventHandlerDirectory, self).__init__(stats)
        self._opener = opener
        self._closer = closer
        self._reader = reader
        self._restart_file_inotify = restart_file_inotify
        self._file = filename

    def process_IN_CREATE(self, event):
        """docstring for process_IN_CREATE"""
        if event.pathname == self._file:
            self._restart_file_inotify()
            self._opener()
            self._reader()

    def process_IN_DELETE(self, event):
        if event.pathname == self._file:
            self._closer()


class EventHandlerFile(pyinotify.ProcessEvent):

    def __init__(self, stats, reader):
        """ init
            closer: callback for closing file
            reader: callback for reading file
        """
        super(EventHandlerFile, self).__init__(stats)
        self._reader = reader

    def process_IN_MODIFY(self, event):
        self._reader()


class FileTail():

    def __init__(self, path: str, host: str, prefix: str, seek_to_end: bool = True):
        self._path = path
        self._es_host = host
        self._es_index_prefix = prefix

        # prepare file: on initial open we want to seek to the end
        self._filehandle = None
        self.open()
        if seek_to_end:
            self._filehandle.seek(0, 2)

        self._setup_file_inotify()
        self._setup_dir_inotify()

    def _setup_file_inotify(self):
        """ setup inotify for the actual file
        """
        watch_manager = pyinotify.WatchManager()
        stats = pyinotify.Stats()
        self._notifier_file = pyinotify.ThreadedNotifier(
            watch_manager, default_proc_fun=EventHandlerFile(stats, self.read_new_content))
        self._notifier_file.start()
        self._wdd_file = watch_manager.add_watch(self._path, pyinotify.IN_MODIFY)

        # setup Inotify for the directorselfy
    def _setup_dir_inotify(self):
        """ setup inotify for the directory
        """
        path = re.sub(r"/[^/]+$", "", self._path)
        watch_manager = pyinotify.WatchManager()
        stats = pyinotify.Stats()
        self._notifier_dir = pyinotify.ThreadedNotifier(
            watch_manager,
            default_proc_fun=EventHandlerDirectory(stats, self.open, self.close, self.read_new_content,
                                                   self._setup_file_inotify, self._path))
        self._notifier_dir.start()
        self._wdd_file = watch_manager.add_watch(path, pyinotify.IN_CREATE | pyinotify.IN_DELETE)

    def open(self):
        if not self._filehandle:
            self._filehandle = open(self._path)

    def close(self):
        """ close the file
        """
        if self._filehandle:
            self._filehandle.close()
            self._filehandle = None

    def read_new_content(self):
        """ read line from the file
        """
        es = Elasticsearch(hosts=[self._es_host])
        index = self._es_index_prefix + datetime.datetime.today().strftime('%Y-%m-%d')
        if self._filehandle:
            for line in self._filehandle.readlines():
                blob = get_es_blob(line.strip())
                if blob:
                    id = hashlib.sha256(json.dumps(blob).encode()).hexdigest()
                    es.index(index=index, doc_type='syslog', id=id, body=blob)

    def run(self):
        """ start main processing
        """
        while True:
            try:
                time.sleep(10)
            except KeyboardInterrupt:
                self._notifier_file.stop()
                self._notifier_dir.stop()
                break
            except:
                self._notifier_file.stop()
                self._notifier_dir.stop()
                raise


@click.command()
@click.option('-v', '--verbosity', help='Verbosity', default=0, count=True)
@click.option('-h', '--elasticsearch-host', help='Host to send the logs to', required=True)
@click.option('-i', '--index-prefix', help='Index to send the logs to', required=True)
@click.argument('path', required=True)
def cli(verbosity: str, elasticsearch_host: str, index_prefix: str, path: str):
    """ main program
    """
    _configure_logging(verbosity)
    app = FileTail(path=path, host=elasticsearch_host, prefix=index_prefix)
    app.run()


if __name__ == '__main__':
    # pylint: disable=E1120
    sys.exit(cli())

