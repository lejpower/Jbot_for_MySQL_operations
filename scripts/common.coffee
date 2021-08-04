# Description:
# 
# Author : Uijun.Lee
# Date   : 2015/01/13
#


os_mng_tool_url = process.env.OS_MNG_TOOL_URL
os_mng_tool_host= process.env.OS_MNG_TOOL_HOST
os_mng_tool_team= process.env.OS_MNG_TOOL_TEAM
# Jmysql_monitor_auth= process.env.JMYSQL_MONITOR_AUTH

OSmonitor_url=process.env.OS_MONITOR_URL

Jmysql_monitor_url= process.env.JMYSQL_MONITOR_URL
Jmysql_monitor_auth= process.env.JMYSQL_MONITOR_AUTH

db_mng_tool_url= process.env.DB_MNG_TOOL_URL
db_mng_tool_auth= process.env.DB_MNG_TOOL_AUTH


async = require('async')
util = require('util')
parseXML = require('xml2js').parseString
exec = require('child_process').exec
request = require 'request'

module.exports = (robot) ->

	# Log
	logs = do->
		data: []
		push: (msg)->
			console.log msg
			this.data.push [new Date, msg]
		get: ->
			this.data

	# Jmysql_monitor
	searchJmonitorHost = (msg, host, callback)->
		url = "#{Jmysql_monitor_url}" + "/instances.json?"
		url += "host_name=#{host}&commit=Search&" + "#{Jmysql_monitor_auth}"
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			logs.push "[INFO] Start Jmonitor search process"

	# usages
	robot.hear /link help/i, (msg) ->
		msg.send "Usage: ilink hostname"
		msg.send "Usage: os_mng_tool url hostname"
		msg.send "Usage: OSmonitor(pdr) hostname"
		msg.send "Usage: Jmysql_monitor url hostname"
		msg.send "Usage: db_mng_tool url hostname"

	# url for OSmonitor
	robot.hear /OSmonitor (.+)/i, (msg) ->
		logs.push "[INFO] Start OSmonitor search proess"
		host = msg.match[1].trim()
		msg.send "OS_MONITOR URL for #{host} =>\n" + OSmonitor_url + "_" + "#{host}"

	# url for OSmonitor
	robot.hear /pdr (.+)/i, (msg) ->
		logs.push "[INFO] Start OSmonitor search proess"
		host = msg.match[1].trim()
		msg.send "OS_MONITOR URL for #{host} =>\n" + OSmonitor_url + "_" + "#{host}"

	# url for os_mng_tool, OSmonitor, db_mng_tool, Jmysql_monitor
	robot.hear /ilink (.+)/i, (msg) ->
		logs.push "[INFO] Start os_mng_tool search proess"
		host = msg.match[1].trim()
		async.waterfall [
			(callback)->
				logs.push "[INFO] Request for db_mng_tool url"
				searchJmonitorHost msg, host, (data)->
					try
						Jmysql_monitor_id = data[0].id
						db_mng_tool_id = data[0].db_mng_tool_id
						host = data[0].host_name
					catch err
						msg.send "/code\n[Error] Target host \"#{host}\" not found"
						throw err
					msg.send "[ Links for #{host} ]"
					msg.send "JMYSQL_MONITOR\n" + Jmysql_monitor_url + "/instances/" + Jmysql_monitor_id + "?alive=true"
					msg.send "DB_MNG_TOOL MySQL\n" + db_mng_tool_url + "/instances/" + db_mng_tool_id
					callback err, host
			(host, callback)->
				logs.push "[INFO] Request for os_mng_tool url"
				url = "#{os_mng_tool_host}" + host
				msg.http(url).get() (err, res, body) ->
					parseXML body, {}, (err, data)->
						try
							os_mng_tool_id = data.os_mng_toolinfo.host_list[0].host[0].id[0]
						catch err
							msg.send "/code\n[Error] Target host \"#{host}\" not found"
							throw err
						msg.send "OS_MNG_TOOL\n" + os_mng_tool_url + "/host/detail/id/" + os_mng_tool_id
						msg.send "OS_MONITOR\n" + OSmonitor_url + "_" + "#{host}"
					
		], (err, results)->
			if err then throw err
			logs.push "[INFO] End os_mng_tool search proess"
