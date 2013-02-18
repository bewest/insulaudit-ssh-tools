#!/usr/bin/env python

import os, sys
from urlparse import urlparse, parse_qsl

uri = sys.argv[1]
result = urlparse(uri)
host = result.netloc.split('@')
user, host = host[1:] and host or ['', host[0]]
user = user.split(':')
user, passw = user[1:] and user or [user[0], '']
host = host.split(':')
host, port = host[1:] and host or [host[0], '']
path = result.path
query = result.query
frag = result.fragment
print 'user=%s' % user
print 'passw=%s' % passw 
print 'host=%s' % host
print 'path=%s' % path
print 'port=%s' % port
print 'query=%s' % parse_qsl(query)
for k, v in parse_qsl(query):
  print '%s=%s' % (k, v)
print 'frag=%s' % frag
#####
# EOF
