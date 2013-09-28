#!/usr/bin/python

import sys
from sys import stdin, stdout, exit
import json
import urllib2
import time

# NOTE: could add metro
NDT_HOSTLIST = [ "ndt.nodar.measurement-lab.org", 
                 "ndt.iupui.nodar.measurement-lab.org" ]

def log_msg(msg):
    stdout.write("LOG\t"+msg.replace('\t', ' '))

def query_to_dict(query_str):
    fields = query_str.split("\t")
    ret = {}
    if len(fields) == 6:
        (kind, qname, qclass, qtype, id, ip) = fields
    elif len(fields) == 2:
        (qname, qclass, qtype, ip) = (None, None, None, None)
        (kind, id) = fields
    else:
        msg = "FAILED to parse query: %s\n" % query_str
        log_msg(msg)
        return None
    ret['kind'] = kind
    ret['name'] = qname
    ret['class'] = qclass
    ret['type'] = qtype
    ret['id'] = id
    ret['remote_ip'] = ip
    return ret

def handle_mlabns_lookup(query):
    """ issue lookup to mlab-ns with given 'remote_ip' in 'query' """
    try:
        url = 'http://ns.measurementlab.net/ndt?ip=%s' % query['remote_ip']
        resp = urllib2.urlopen(url)
    except:
        msg = "Exception during query for /ndt?ip=%s : %s\n" % (ip, str(e))
        log_msg(msg)
        return
 
    ns_resp = json.load(resp)
    query['ndt_ip'] = ns_resp['ip'][0]

    reply = "DATA\t%(name)s\t%(class)s\tA\t60\t%(id)s\t%(ndt_ip)s\n"
    reply = reply % query
    log_msg(reply)
    stdout.write(reply)

def main():
    # HANDSHAKE
    while True:
        helo = stdin.readline()
        if "HELO" in helo:
            stdout.write("OK\tM-Lab Backend\n")
            stdout.flush()
            break
        # NOTE: recommended behavior is to not exit, try again, and wait to be 
        # terminated. http://doc.powerdns.com/html/backends-detail.html
        print "FAIL"

    # PROCESS QUERIES
    while True:
        query_str = stdin.readline().strip()
        log_msg("RECEIVED: %s\n" % query_str)
        query = query_to_dict(query_str)
        if (query is not None and query['kind'] == "Q" and
            query['name'] in NDT_HOSTLIST):

            # NOTE: the name requested is one we support.
            if query['type']=="SOA":
                reply  = "DATA\t%(name)s\t%(class)s\tSOA\t60\t-1\tlocalhost. "
                reply += "support.measurementlab.net. "
                reply += "2008080300 1800 3600 604800 3600\n" 
                reply = reply % query
                log_msg(reply)
                stdout.write(reply)
            elif query['type'] in [ "ANY", "A" ]:
                handle_mlabns_lookup(query)
                handle_mlabns_lookup(query)

        stdout.write("END\n")
        stdout.flush()

if __name__ == "__main__":
    main()
