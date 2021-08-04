#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import json, urllib2
import urllib
import requests


def _put_data(thre_id, target_value, current_value, host, port, category_id):
	param = {'auth_token': "${TOKEN}", 'threshold[value]':target_value}
	get_thre_url = "https://Jmysql_monitor/thresholds/" + str(thre_id) +".json"
        p = requests.put(get_thre_url, data=param)
	if (p.status_code != 201):
		print("(failed) Threshold change was failed.")
	else:
		print("(successful) Threshold was successfully changed from " + str(current_value) + " to " + str(target_value) + ".")
	print("-------------------------------------------")
	print("Host : " + str(host))
	print("Port : " + str(port))
	print("Category ID : " + str(category_id))
	print("Old Value : " + str(current_value))
	print("New Value : " + str(target_value))
	print("-------------------------------------------")
	return p.status_code


def main():
	argvs = sys.argv 	
	target_value = argvs[1]
	thre_id = argvs[2]
	current_value = argvs[3]
	host = argvs[4]
	port = argvs[5]
	category_id = argvs[6]

	exe_code = _put_data(thre_id, target_value, current_value, host, port, category_id)
	exit(exe_code)


if __name__ == '__main__':
	main()
