#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import json, urllib2
import urllib
import requests


def _put_data(thre_id, target_actual_flg, current_flg, host, port, category_id, target_flg):
	param = {'auth_token': "${TOKEN}", 'threshold[monitoring]':target_actual_flg}
	get_thre_url = "https://Jmysql_monitor/thresholds/" + str(thre_id) +".json"
        p = requests.put(get_thre_url, data=param)
	if (p.status_code != 201):
		print("(failed) Monitoring change was failed.")
	else:
		print("(successful) Monitoring flag was successfully changed from " + str(current_flg) + " to " + str(target_flg) + ".")
	print("-------------------------------------------")
	print("Host : " + str(host))
	print("Port : " + str(port))
	print("Category ID : " + str(category_id))
	print("Old Flag : " + str(current_flg))
	print("New Flag : " + str(target_flg))
	print("-------------------------------------------")
	return p.status_code


def main():
	argvs = sys.argv 	
	target_flg = argvs[1]
	thre_id = argvs[2]
	current_flg = argvs[3]
	host = argvs[4]
	port = argvs[5]
	category_id = argvs[6]

	if (target_flg == "on"):
		target_actual_flg = "true"
	else:
		target_actual_flg = "false"

	if (current_flg == "true"):
		current_flg = "on"
	else:
		current_flg = "off"

	exe_code = _put_data(thre_id, target_actual_flg, current_flg, host, port, category_id, target_flg)
	exit(exe_code)


if __name__ == '__main__':
	main()
