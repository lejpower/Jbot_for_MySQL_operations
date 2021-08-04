#! /usr/bin/env python
#  -*- coding: utf-8 -*-

# Description:
#
# Author : Uijun.Lee
# Date   : 2015/01/13
#

import sys
import os
import json
import time
import urllib2
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime as dt


Jmysql_monitor_url = os.environ.get("JMYSQL_MONITOR_URL")
Jmysql_monitor_auth = os.environ.get("JMYSQL_MONITOR_AUTH")


color_table = list('bgrcmykw')
type_table = {
    "iostat": {
        "key"   : "iostats",
        "span"  : "1hour",
        "fields": ["read_io_avr", "write_io_avr"],
        "cumu"  : False,
    },
    "disk": {
        "key"   : "disks",
        "span"  : "1day",
        "fields": ["used_g", "total_g"],
        "cumu"  : False,
    },
    "memory": {
        "key"   : "memories",
        "span"  : "1day",
        #"span"  : "1hour",
        "fields": ["used", "free", "total"],
        "cumu"  : False,
    },
    "load": {
        "key"   : "loads",
        "span"  : "1hour",
        "fields": ["one_min_average", "fifteen_min_average", "five_min_average"],
        "cumu"  : False,
    },
    "replication": {
        "key"   : "replications",
        "span"  : "1day",
        #"span"  : "1hour",
        "fields": ["seconds_behind_master"],
        "cumu"  : False,
    },
    "com_status": {
        "key"   : "statuses",
        "span"  : "1hour",
        "fields": ["com_select","com_insert","com_update","com_delete","com_insert_select","com_load"],
        "cumu"  : True,
    },
    "threads_status": {
        "key"   : "statuses",
        "span"  : "1hour",
        "fields": ["threads_connected","threads_running"],
        "cumu"  : False,
    },
    "slow_query": {
        "key"   : "statuses",
        "span"  : "1hour",
        "fields": ["slow_queries"],
        "cumu"  : True,
    },
    "tmp_table": {
        "key"   : "statuses",
        "span"  : "1hour",
        "fields": ["created_tmp_tables","created_tmp_disk_tables"],
        "cumu"  : True,
    },
}
for k in type_table:
    type_table[k]['fields'].append('created_at')

def generate_name(host_id):
    return time.strftime("/tmp/Jmysql_monitor." + host_id + ".%Y%m%d.%H%M%S.png")

def get_data(host_id, data_type):
    url = str(Jmysql_monitor_url)
    url += "/instances/%s/%s.json" % (host_id, type_table[data_type]["key"])
    url += "?commit=Search"
    url += "&" + str(Jmysql_monitor_auth)
    url += "&range=%s" % type_table[data_type]["span"]
    return json.loads(urllib2.urlopen(url).read())

def format_data(results, data_type):
    data = {}
    last = {}
    for i in type_table[data_type]["fields"]:
        data[i] = []
        last[i] = 0
    
    for idx,result in enumerate(results):
        for k,v in result.items():
            if not k in type_table[data_type]["fields"]: continue
            if not (type_table[data_type]["cumu"] == True and idx == 0):
                if ( k == "created_at"):
                    data[k].append(v)
                else:
                    if v == None: v = 0
                    data[k].append(v - last[k])
            if type_table[data_type]["cumu"] == True:
                last[k] = v
    return data

def format_date(results, data_type):
    tmp = {}
    for i in type_table[data_type]['fields']:
        tmp[i] = []
    for idx,result in enumerate(results):
        for k,v in result.items():
            if not k in type_table[data_type]["fields"]: continue
            if not (type_table[data_type]["cumu"] == True and idx == 0):
                tmp[k].append(v)

    tmp_result = []
    for i in tmp["created_at"]:
       d_tmp = str(i).split('-')
       y = d_tmp[0]
       m = d_tmp[1]
       t_tmp = d_tmp[2].split('T')
       d = t_tmp[0]
       t = t_tmp[1].split(':')
       h = t[0]
       M = t[1]
       s = t[2].split('+')[0]
       tmp_date = dt.strptime(y+'-'+m+'-'+d+' '+h+':'+M+':'+s, '%Y-%m-%d %H:%M:%S')
       convert_int_time = int(time.mktime(tmp_date.timetuple()))
       tmp_result.append(convert_int_time)
    data = tmp_result
    return data

def main():
    # Arguments
    if len(sys.argv) < 3:
        print "Usage: python image.py host_id graph_name data_type"
        exit()
    host_id = sys.argv[1]
    data_type = sys.argv[3]
    graph_name = sys.argv[2] + "\n(type:" + data_type + " / span:" + type_table[data_type]["span"] + ")"

    # Get information
    name = generate_name(host_id)
    result = format_data(
        get_data(host_id, data_type),
        data_type
    )
    x_date = format_date(
        get_data(host_id, data_type),
        data_type
    )
    dts = map(dt.fromtimestamp, x_date)

    # Plot graph
    plt.figure(figsize=(12, 6))
    plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
    for k,v in result.items():
        if ( k != "created_at"):
            plt.plot(dts, v, color_table.pop(0), label=k)
            plt.gcf().autofmt_xdate()
    plt.legend()

    # Configure graph
    plt.title(graph_name)
    plt.ylim(0)
    plt.grid(True)
    plt.savefig(name)

    # Return path
    print name

if __name__ == "__main__":
    main()
