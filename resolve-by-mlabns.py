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

def data_msg(msg):
    log_msg("REPLY: "+msg)
    stdout.write("DATA\t"+msg)

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

def soa_record(query):
    """ Formats an SOA record using fields in 'query' and global values.
    Return string is suitable for printing in a 'DATA' reply to pdns.

    Example (split across two lines for clarity):
        ndt.iupui.nodar.measurement-lab.org IN SOA 60 -1 localhost. \\
            support.measurementlab.net. 2013092700 1800 3600 604800 3600\\n

    TODO: these values are like DONAR, but confirm that the fields make sense.
    """
    reply  = "%(name)s\t"
    reply += "%(class)s\t"
    reply += "SOA\t"
    reply += "60\t"
    reply += "-1\t"
    reply += "localhost. "
    reply += "support.measurementlab.net. "
    reply += "2013092700 1800 3600 604800 3600\n"
    return reply % query

def a_record(query, ipaddr):
    """ Formats an A record using fields in 'query' and ipaddr, suitable for
    printing in a 'DATA' reply to pdns.

    Example:
        ndt.iupui.nodar.measurement-lab.org IN A 60 -1 192.168.1.2\\n
    """
    reply  = "%(name)s\t"
    reply += "%(class)s\t"
    reply += "A\t"
    reply += "60\t"
    reply += "%(id)s\t"
    reply += ipaddr+"\n"
    return reply % query

def mlabns_a_record(query):
    """ issue lookup to mlab-ns with given 'remote_ip' in 'query' """
    try:
        url = 'http://ns.measurementlab.net/ndt?ip=%s' % query['remote_ip']
        resp = urllib2.urlopen(url)
    except:
        msg = "Exception during query for /ndt?ip=%s : %s\n" % (ip, str(e))
        log_msg(msg)
        return
 
    ns_resp = json.load(resp)
    if 'ip' not in ns_resp or len(ns_resp['ip']) == 0:
        msg = "mlab-ns response missing 'ip' field: %s\n" % ns_resp
        log_msg(msg)
        return
        
    # TODO: if len > 1, return all. Are multiple IPs supported by mlab-ns?
    ndt_ip = ns_resp['ip'][0]
    return a_record(query, ndt_ip)

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
        query_str = stdin.readline()
        if query_str == "": break # EOF

        query_str = query_str.strip()
        query = query_to_dict(query_str)
        log_msg("INPUT: %s\n" % query_str)

        # NOTE: if this is a valid query, for a name we support.
        if (query is not None and query['kind'] == "Q" and
            query['name'] in NDT_HOSTLIST):

            if query['type']=="SOA":
                data_msg(soa_record(query))
            elif query['type'] in [ "ANY", "A" ]:
                data_msg(mlabns_a_record(query))
                data_msg(mlabns_a_record(query))

        stdout.write("END\n")
        stdout.flush()

if __name__ == "__main__":
    main()
