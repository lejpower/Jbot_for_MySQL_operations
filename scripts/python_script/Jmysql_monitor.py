#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import json, urllib2
import urllib
import requests

global Jmysql_monitor_url
global Jmysql_monitor_auth_token
global target_host
global error_item
global no_monitor_item
global repl_item
global disk_item
global thread_item
global memory_item
global load_item
global all_item

#Jmysql_monitor_url = os.environ.get("JMYSQL_MONITOR_URL")
#Jmysql_monitor_auth_token = os.environ.get("JMYSQL_MONITOR_AUTH_TOKEN")
#dev_proxy = os.environ.get("DEV_PROXY")

def _get_target_host_info(Jmysql_monitor_url, Jmysql_monitor_auth_token, target_host):
    get_Jmysql_monitor_url = ''
    get_Jmysql_monitor_url = Jmysql_monitor_url + "instances.json?" + Jmysql_monitor_auth_token
    get_Jmysql_monitor_url = get_Jmysql_monitor_url + "&host_name=" + target_host
    return get_Jmysql_monitor_url

def _get_category_url(Jmysql_monitor_url, Jmysql_monitor_auth_token):
    get_Jmysql_monitor_url = ''
    get_Jmysql_monitor_url = Jmysql_monitor_url + "categories.json?" + Jmysql_monitor_auth_token
    return get_Jmysql_monitor_url

def _get_threshold_url(Jmysql_monitor_url, Jmysql_monitor_id, Jmysql_monitor_auth_token, target_host, item):
    get_Jmysql_monitor_url = ''
    get_Jmysql_monitor_url = Jmysql_monitor_url + "instances/" + str(Jmysql_monitor_id) + "/thresholds.json"
    get_Jmysql_monitor_url = get_Jmysql_monitor_url + "?host_name=" + target_host + "&category%5Bid%5D=" + str(item) + "&" + Jmysql_monitor_auth_token + "&commit=SEARCH"
    return get_Jmysql_monitor_url

def _get_data(url):
    f1 = urllib2.urlopen(url)
    result = json.loads(f1.read())
    return result  

def _put_data(get_thre_url , Jmysql_monitor_id ,thre_id, item, target_value , level):
	param = {'auth_token': "${TOKEN}", 'threshold[instance_id]':Jmysql_monitor_id, 'threshold[category_id]':item , 'threshold[value]':target_value , 'threshold[level]':level}
	get_thre_url = "http://Jmysql_monitor/thresholds/" + str(thre_id) +".json"
	p = requests.put(get_thre_url, data=param)
	if (p.status_code != 204):
		print("FAILED TO UPDATED")
	return p.status_code
	
def _argv_check(argvs):
	err_code = 0
	host = ''
	argc = len(argvs)
	
	error_item = ["Error" , "error","err","Err","e"]
	no_monitor_item = ["monitor","Monitor","Mon", "mon","nm"]
	repl_item = ["replication", "Replication", "repl", "Repl","r"]
	disk_item = ["Disk" , "disk","d"]
	thread_item = ["Threshold","threshold","thre","Thre","t", "th"]
	memory_item = ["Memory", "memory", "mem", "Mem","mm"]
	load_item = ["Load", "load", "l", "ld"]
	check_item = [load_item, disk_item, thread_item, repl_item, error_item, memory_item, no_monitor_item]
	
	# chk number
	# 1 = Load Average
	# 2 = Disk Size
	# 3 = Threads
	# 4 = Replication
	# 5 = Error Log
	# 6 = Memory
	# 7 = No Monitor Log
	if (argc == 4):
		chk = 0
		for c in check_item:
			for i in c:
				if (argvs[2] == i):
					item = chk + 1
			chk = chk + 1
		all_item = load_item + error_item + no_monitor_item + repl_item + disk_item + thread_item + memory_item
		
		if (argc != 4):
			err_code = 1
		elif (argvs[2] not in all_item):
			err_code = 1	
	else:
		err_code = 1
		item = 0
	return err_code, item

def main():
	argvs = sys.argv 	
	argc = len(argvs)
	err_code, item  = _argv_check(argvs)
	if (err_code != 0):
		print("Error!!")
		exit(1)
	
	Jmysql_monitor_url = "http://Jmysql_monitor/admin/"
	Jmysql_monitor_url_not_admin = "http://Jmysql_monitor/"
	Jmysql_monitor_auth_token = "auth_token=${TOKEN}"
	target_host = argvs[1]
	target_value = argvs[3]
	
	#get target host information
	get_target_url = _get_target_host_info(Jmysql_monitor_url, Jmysql_monitor_auth_token, target_host)
	Jmysql_monitor_id = (_get_data(get_target_url))[0]["id"]
	
	# get category
	get_category_url = _get_category_url(Jmysql_monitor_url, Jmysql_monitor_auth_token)
        Jmysql_monitor_category = _get_data(get_category_url)	
	
	get_thre_url = _get_threshold_url(Jmysql_monitor_url_not_admin, Jmysql_monitor_id, Jmysql_monitor_auth_token, target_host, item)
        target_thre = _get_data(get_thre_url)	
	thre_id = target_thre[0]["id"]
	
	for th in target_thre:
		if (th["category_id"] == item):
			print("Current value : " + str(th["value"]))
			print("Target  value : " + str(target_value))
			exe_code = _put_data(get_thre_url , Jmysql_monitor_id , thre_id, item, target_value , level = 3)
	
	exit(exe_code)
	

if __name__ == '__main__':
    main()
