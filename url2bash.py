#!/usr/bin/env python

import os, sys
from urlparse import urlparse

uri = sys.argv[1]
result = urlparse(uri)
user, host = result.netloc.split('@')
host, port = host.split(':')
path = result.path
print('user=', user)
print('host=', host)
print('path=', path)
print('port=', port)