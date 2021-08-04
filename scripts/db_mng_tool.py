#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import json, urllib2
import urllib
import requests

def _put_data(db_mng_tool_id, parameter, value, host, port):
	param = {'auth_token': "${TOKEN}", 'parameter[name]':parameter, 'parameter[value]':value}
	change_param_url = "http://MySQL_management_tool/instances/" + str(db_mng_tool_id) + "/instance_variable/change_parameter.json"
	p = requests.put(change_param_url, data=param)
	if (p.status_code != 200):
		print("(failed) Parameter change was failed.")
		print("From DB_MNG_TOOL API : " + str(p.text))
	else:
		print("(successful) Parameter change was successful.")
		print("From DB_MNG_TOOL API : " + str(p.text))
	print("-------------------------------------------")
	print("Host : " + str(host))
	print("Port : " + str(port))
	print("Parameter : " + str(parameter))
	print("Value : " + str(value))
	print("-------------------------------------------")
	print("DB_MNG_TOOL URL : https://db_mng_tool-mysql/instances/" + str(db_mng_tool_id) + "/instance_variable?variables_name=" + str(parameter))
	return p.status_code

def main():
	argvs = sys.argv
	target_id = argvs[1]
	target_parameter = argvs[2]
	target_value = argvs[3]
	target_host = argvs[4]
	target_port = argvs[5]

	exe_code = _put_data(target_id, target_parameter, target_value, target_host, target_port)
	exit(exe_code)


if __name__ == '__main__':
	main()
