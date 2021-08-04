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
global on_item
global off_item
global item_collection

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
    if ( item == 8 ):
       get_Jmysql_monitor_url = get_Jmysql_monitor_url + "?host_name=" + target_host + "&category%5Bid%5D=&" + Jmysql_monitor_auth_token + "&commit=SEARCH"
    else:
       get_Jmysql_monitor_url = get_Jmysql_monitor_url + "?host_name=" + target_host + "&category%5Bid%5D=" + str(item) + "&" + Jmysql_monitor_auth_token + "&commit=SEARCH"
    return get_Jmysql_monitor_url

def _get_data(url):
    f1 = urllib2.urlopen(url)
    result = json.loads(f1.read())
    return result  

def _put_data(get_thre_url , Jmysql_monitor_id ,thre_id, item, monitor , level):
	param = {'auth_token': "${TOKEN}", 'threshold[instance_id]':Jmysql_monitor_id, 'threshold[category_id]':item , 'threshold[monitoring]':monitor , 'threshold[level]':level}
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
	all_item = ["All", "all", "ALL", "a"]
	on_item = ["on", "ON", "On"]
	off_item = ["off", "OFF", "Off"]
	check_item = [load_item, disk_item, thread_item, repl_item, error_item, memory_item, no_monitor_item, all_item]
	
	# chk number
	# 1 = Load Average
	# 2 = Disk Size
	# 3 = Threads
	# 4 = Replication
	# 5 = Error Log
	# 6 = Memory
	# 7 = No Monitor Log
	# 8 = all
	if (argc == 4):
		chk = 0
		for c in check_item:
			for i in c:
				if (argvs[2] == i):
					item = chk + 1
			chk = chk + 1
		item_collection = load_item + error_item + no_monitor_item + repl_item + disk_item + thread_item + memory_item + all_item
		
		if (argc != 4):
			err_code = 1
		elif (argvs[2] not in item_collection):
			err_code = 1	
		elif (argvs[3] not in (on_item+off_item)):
			err_code = 1	
	else:
		err_code = 1
		item = 0
	return err_code, item, on_item, off_item, all_item

def main():
	argvs = sys.argv 	
	argc = len(argvs)
	err_code, item, on_item , off_item, all_item  = _argv_check(argvs)
	if (err_code != 0):
		print("Error!!")
		exit(1)
	
	Jmysql_monitor_url = "http://Jmysql_monitor/admin/"
	Jmysql_monitor_url_not_admin = "http://Jmysql_monitor/"
	Jmysql_monitor_auth_token = "auth_token=${TOKEN}"
	target_host = argvs[1]
	
	# value (on / off)
	target_value = argvs[3]
	
	#get target host information
	get_target_url = _get_target_host_info(Jmysql_monitor_url, Jmysql_monitor_auth_token, target_host)
	Jmysql_monitor_id = (_get_data(get_target_url))[0]["id"]
	
	# get category
	get_category_url = _get_category_url(Jmysql_monitor_url, Jmysql_monitor_auth_token)
        Jmysql_monitor_category = _get_data(get_category_url)	
	
	if (item != 8):
		get_thre_url = _get_threshold_url(Jmysql_monitor_url_not_admin, Jmysql_monitor_id, Jmysql_monitor_auth_token, target_host, item)
        	target_thre = _get_data(get_thre_url)	
		##thre_id = target_thre[0]["id"]
	else:
		get_thre_url = _get_threshold_url(Jmysql_monitor_url_not_admin, Jmysql_monitor_id, Jmysql_monitor_auth_token, target_host, item)
        	target_thre = _get_data(get_thre_url)	
	
        if (target_value in on_item):
                monitor = 1
        elif (target_value in off_item):
                monitor = 0

	for i in target_thre:
		
		thre_id = i["id"]	
		if (item != 8):	
			#for th in i:
			if (i["category_id"] == item):
				##if (str(i["monitoring"]) == "True"):
				##	print("Current value : on")
				##elif (str(i["monitoring"]) == "False"):
				##	print("Current value : off")
				print("Updated : " + str(target_value))
				exe_code = _put_data(get_thre_url , Jmysql_monitor_id , thre_id, item, monitor , level = 3)
		if (item == 8):	
			##if (str(i["monitoring"]) == "True"):
			##	print("Current value : on")
			##elif (str(i["monitoring"]) == "False"):
			##	print("Current value : off")
			print("Updated : " + str(target_value))
			exe_code = _put_data(get_thre_url , Jmysql_monitor_id , thre_id, i["category_id"], monitor , level = 3)
		
		##print(exe_code)		
		print("")	
	##print("Jmysql_mon stat " + target_host)	
	exit(exe_code)

if __name__ == '__main__':
    main()
