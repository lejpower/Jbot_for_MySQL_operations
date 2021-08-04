# Description:
# 
# Author : Uijun.Lee
# Date   : 2015/01/13
#


os_mng_tool_url = process.env.OS_MNG_TOOL_URL
os_mng_tool_host= process.env.OS_MNG_TOOL_HOST
os_mng_tool_team= process.env.OS_MNG_TOOL_TEAM
# Jmysql_monitor_auth= process.env.JMYSQL_MONITOR_AUTH

async = require('async')
util = require('util')
parseXML = require('xml2js').parseString
exec = require('child_process').exec

module.exports = (robot) ->

	# Log
	logs = do->
		data: []
		push: (msg)->
			console.log msg
			this.data.push [new Date, msg]
		get: ->
			this.data

	# ios_mng_tool
	robot.hear /os_mng_tool help/i, (msg) ->
		msg.send "Usage: ios_mng_tool hostname app|sys"
		msg.send "Usage: ios_mng_tool url hostname"
	
	
	robot.hear /os_mng_tool (.+) (app|sys)/i, (msg) ->
		logs.push "[INFO] Start os_mng_tool search proess"
		team = msg.match[2] + "_team"
		host = msg.match[1].trim()
		async.waterfall [
			# host
			(callback)->
				logs.push "[INFO] Request for host"
				url = "#{os_mng_tool_host}" + host
				msg.http(url).get() (err, res, body) ->
					parseXML body, {}, (err, data)->
						try
							team = data.os_mng_toolinfo.host_list[0].host[0][team][0]
							os_mng_tool_id = data.os_mng_toolinfo.host_list[0].host[0].id[0]
						catch err
							msg.send "/code\n[Error] Target host \"#{host}\" not found"
							throw err
						msg.send "OS_MNG_TOOL URL: " + os_mng_tool_url + "/host/detail/id/" + os_mng_tool_id
						msg.send "/code\n" + "#{msg.match[2]} team of \"#{host}\" is \"#{team}\", searching emergency contact ..."
						callback err, team
			# team
			(team, callback)->
				logs.push "[INFO] Request for team \"#{team}\""
				url = "#{os_mng_tool_team}" + team
				msg.http(url).get() (err, res, body) ->
					parseXML body, {}, (err, results)->
						contacts = []
						try
							results = results.os_mng_toolinfo.team_list[0].team[0]
						catch err
							msg.send "/code\n[Error] Target team \"#{team}\" not found"
							throw err
						for i in [1..5]
							tmp = results['emergency'+i]
							if tmp?[0]?.account[0]? and tmp[0].account[0]
								contacts.push tmp[0]
						callback err,
							team: team
							contacts: contacts
		# output
		], (err, results)->
			if err then throw err
			data = []
			data.push '/code'
			if results.contacts.length == 0
				data.push "No emergency contacts found in team \"#{results.team}\""
			else
				data.push "Following is the emergency contacts of team \"#{results.team}\""
				for i,idx in results.contacts
					data.push "#{idx+1}. #{i.account[0]} / #{i.name[0]} (#{i.tel[0]})"
			msg.send data.join("\n")
			logs.push "[INFO] End os_mng_tool search proess"

	# os_mng_tool url
	robot.hear /os_mng_tool url (.+)/i, (msg) ->
		logs.push "[INFO] Start os_mng_tool search proess"
		host = msg.match[1].trim()
		async.waterfall [
			(callback)->
				logs.push "[INFO] Request for os_mng_tool url"
				url = "#{os_mng_tool_host}" + host
				msg.http(url).get() (err, res, body) ->
					parseXML body, {}, (err, data)->
						try
							os_mng_tool_id = data.os_mng_toolinfo.host_list[0].host[0].id[0]
						catch err
							msg.send "/code\n[Error] Target host \"#{host}\" not found"
							throw err
						msg.send "OS_MNG_TOOL URL for #{host} =>\n" + os_mng_tool_url + "/host/detail/id/" + os_mng_tool_id
		], (err, results)->
			if err then throw err
			logs.push "[INFO] End os_mng_tool search proess"
		logs.push "[INFO] End os_mng_tool search proess" 
