#!/usr/bin/env python

import sys
import json

j=json.load(sys.stdin)
k=j['_meta']['hostvars']

#if len(k.keys()) > 1:
#   print "Error"

for x in k.keys():
  print "  - job_name: 'cadvisor at %s'" % (x)
  print "    scrape_interval: 5s"
  print "    static_configs:"
  print "      - targets: ['%s:8080']" % (x)
  print ""


  print "  - job_name: 'Linux at %s'" % (x)
  print "    scrape_interval: 5s"
  print "    static_configs:"
  print "      - targets: ['%s:9100']" % (x)
  print ""
