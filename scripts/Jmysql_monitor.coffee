# Description:
#
# Author : Uijun.Lee  
# Date   : 2015/01/13
#

Jmysql_monitor_url= process.env.JMYSQL_MONITOR_URL
Jmysql_monitor_auth= process.env.JMYSQL_MONITOR_AUTH

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

	robot.hear /histor/i, (msg) ->
		data = "/code" + "\n" + util.inspect logs.get(), false, null
		msg.send data

	robot.respond /test/i, (msg) ->
		msg.send "I'm alive!"
　　
　　
	# Jmysql_monitor
	searchJmonitorHost = (msg, host, callback)->
		url = "#{Jmysql_monitor_url}" + "/instances.json?"
		url += "host_name=#{host}&commit=Search&" + "#{Jmysql_monitor_auth}"
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchJmonitorHost----------"

	searchJmonitorThreshold = (msg, id, callback)->
		url = "#{Jmysql_monitor_url}" + "/instances/" + "#{id}" + "/thresholds.json"
		url += "?" + "#{Jmysql_monitor_auth}"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchJmonitorThreshold----------"

	searchJmonitorThresholdId = (msg, id, host, category_id, callback)->
		url = "#{Jmysql_monitor_url}" + "/instances/" + "#{id}" + "/thresholds.json"
		url += "?host_name=#{host}&category%5Bid%5D=#{category_id}&" + "#{Jmysql_monitor_auth}"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchJmonitorThresholdId----------"

	searchJmonitorMember = (msg, id, callback)->
		url = "#{Jmysql_monitor_url}" + "/instances/" + "#{id}" + "/members.json"
		url += "?" + "#{Jmysql_monitor_auth}"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchJmonitorMember----------"

	searchJmonitorUser = (msg, callback)->
		url = "#{Jmysql_monitor_url}" + "/admin/users.json"
		url += "?" + "#{Jmysql_monitor_auth}"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchJmonitorUser----------"

	offJmonitorMonitor = (msg, id, callback)->
		Jmysql_monitor_url = "#{Jmysql_monitor_url}" + "/thresholds/" + "#{id}" + "/edit"
		Jmysql_monitor_url += "?" + "#{Jmysql_monitor_auth}"
		request.post
		  url: '#{Jmysql_monitor_url}'
		  json:
			  Monitoring: 1
		, (err, response, body) ->
		#console.log url
		#msg.http(url, {monitoring : 1}).post() (err, res, body) ->
			#callback JSON.parse(body)
		console.log "-----offJmonitorMonitor----------"

	searchJmonitorCategory = (msg, callback)->
		url = "#{Jmysql_monitor_url}" + "/admin/categories.json"
		url += "?" + "#{Jmysql_monitor_auth}"
		result = msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchJmonitorCategory----------"
　　　
  ### Conversation with HUBOT ###

  # Jmonitor url
	robot.hear /Jmysql_mon off (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			offJmonitorMonitor msg, id, (data)->
				msg.send "successful"

	robot.hear /Jmysql_monitor search (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchJmonitorHost msg, host, (data)->
			data = "/code" + "\n" + util.inspect data, false, null
			msg.send data

	robot.hear /Jmysql_monitor monitor set (.+) (.+) (.+)/i, (msg) ->
		host = msg.match[1].trim()
		category_num = msg.match[2].trim()
		value = msg.match[3].trim()
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			updateJmonitorThreshold msg, id, category_num, value, (data2)->

  ## Available
	robot.hear /Jmysql_monitor help/i, (msg) ->
		types = ["iostat", "disk", "memory", "load", "replication", "com_status", "threads_status", "slow_query", "tmp_table"]
		msg.send "Usage: Jmysql_monitor show(jmshow) ${HOSTNAME} (" + types.join('|') + "|all)"
		msg.send "Usage: Jmysql_monitor url(jmurl) ${HOSTNAME}"
		msg.send "Usage: Jmysql_monitor monitor list"
		msg.send "Usage: Jmysql_monitor monitor status(jmstat) ${HOSTNAME}"
		msg.send "Usage: Jmysql_monitor flg (jmflg) ${HOSTNAME} ${ITEM} on|off"
		msg.send "Usage: Jmysql_monitor member (jmmember) ${HOSTNAME}"
		msg.send "Usage: Jmysql_monitor threshold (jmthre) ${HOSTNAME} ${ITEM} ${VALUE}"
		msg.send "Usage: db_mng_tool slave ${HOSTNAME}"
		#msg.send "Usage: Jmysql_monitor get alert ${HOSTNAME} "
		
	robot.hear /-help/i, (msg) ->
		types = ["iostat", "disk", "memory", "load", "replication", "com_status", "threads_status", "slow_query", "tmp_table"]
		msg.send "Usage: Jmysql_monitor show(jmshow) ${HOSTNAME} (" + types.join('|') + "|all)"
		msg.send "Usage: Jmysql_monitor url(jmurl) ${HOSTNAME}"
		msg.send "Usage: Jmysql_monitor monitor list"
		msg.send "Usage: Jmysql_monitor monitor status(Jmysql_mon stat) ${HOSTNAME}"
		msg.send "Usage: Jmysql_monitor flg (jmflg) ${HOSTNAME} ${ITEM} on|off"
		msg.send "Usage: Jmysql_monitor member (jmmember) ${HOSTNAME}"
		msg.send "Usage: Jmysql_monitor threshold (jmthre) ${HOSTNAME} ${ITEM} ${VALUE}"
		msg.send "Usage: ios_mng_tool ${HOSTNAME} apps|sys"
		msg.send "Usage: db_mng_tool slave ${HOSTNAME}"
		
  # Jmonitor members
	robot.hear /Jmysql_monitor member (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				#return false
			target_id = data[0].id
			searchJmonitorUser msg, (users)->
				member = []
				searchJmonitorMember msg, target_id, (members)->
					for member in members
						for user in users
							if (member.user_id == user.id)
								msg.send "#{user.email}"

	  # Jmonitor members
	robot.hear /jmmember (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				#return false
			target_id = data[0].id
			searchJmonitorUser msg, (users)->
				member = []
				searchJmonitorMember msg, target_id, (members)->
					for member in members
						for user in users
							if (member.user_id == user.id)
								msg.send "#{user.email}"

  # Jmonitor url
	robot.hear /Jmysql_monitor url (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			host = data[0].host_name
			url = "#{Jmysql_monitor_url}" + "/instances/" + "#{id}" + "?alive=true\n"
			url += "=> for #{host}" + "\n"
			msg.send url

  # Jmonitor url
	robot.hear /jmurl (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			host = data[0].host_name
			url = "#{Jmysql_monitor_url}" + "/instances/" + "#{id}" + "?alive=true\n"
			url += "=> for #{host}" + "\n"
			msg.send url

  # Jmonitor show
	robot.hear /Jmysql_monitor show (.+) (.+)/i, (msg) ->
		host = msg.match[1].trim()
		type = msg.match[2].trim()
		types = ["iostat", "disk", "memory", "load", "replication", "com_status", "threads_status", "slow_query", "tmp_table"]
		if not (type in types or type == "all")
			msg.send "No data-type \"#{type}\" found, ..."
			msg.send "Usage: Jmysql_monitor show hostname (" + types.join('|') + "|all)"
			return false
		if type == "all"
			type = types
		else
			type = [type]
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			host = data[0].host_name
			funcs = []
			for t in type
				funcs.push do(t)->
					(callback)->
						msg.send "Generate graph for #{t} of #{host}, ..."
						logs.push "[INFO] Execute Jmysql_monitor python script for #{host}(#{id})"
						command =  "python ~/.nodebrew/Jmysql_monitor_bot/scripts/python_script/image.py \"#{id}\" \"#{host}\" \"#{t}\""
						command += " | python ~/.nodebrew/Jmysql_monitor_bot/scripts/python_script/upload_s3.py"
						console.log command
						exec command, (error, stdout, stderror)->
							msg.send stdout
							callback()
			async.waterfall funcs, (err, results)->
				if err then throw err
				console.log results
  # Jmysql_monitor threshold
	robot.hear /jmthre (.+) (.+) (.+)/i, (msg) ->
		type = ["thre"]
		host = msg.match[1].trim()
		item = msg.match[2].trim()
		value = msg.match[3].trim()
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			host = data[0].host_name
			port = data[0].port_num
			searchJmonitorThresholdId msg, id, host, item, (data1) ->
				thre_id = data1[0].id
				current_value = data1[0].value
				funcs = []
				for t in type
					funcs.push do(t)->
						(callback)->
							command = "python ~/.nodebrew/Jbot_for_MySQL_operations/scripts/Jmysql_monitor.py \"#{value}\" \"#{thre_id}\" \"#{current_value}\" \"#{host}\" \"#{port}\" \"#{item}\""
							console.log command
							exec command, (error, stdout, stderror)->
								msg.send stdout
								callback()
				async.waterfall funcs, (err, results)->
					if err then throw err
					console.log results

  # Jmysql_monitor threshold
	robot.hear /Jmysql_monitor threshold (.+) (.+) (.+)/i, (msg) ->
		type = ["thre"]
		host = msg.match[1].trim()
		item = msg.match[2].trim()
		value = msg.match[3].trim()
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			host = data[0].host_name
			port = data[0].port_num
			searchJmonitorThresholdId msg, id, host, item, (data1) ->
				thre_id = data1[0].id
				current_value = data1[0].value
				funcs = []
				for t in type
					funcs.push do(t)->
						(callback)->
							command = "python ~/.nodebrew/Jbot_for_MySQL_operations/scripts/Jmysql_monitor.py \"#{value}\" \"#{thre_id}\" \"#{current_value}\" \"#{host}\" \"#{port}\" \"#{item}\""
							console.log command
							exec command, (error, stdout, stderror)->
								msg.send stdout
								callback()
				async.waterfall funcs, (err, results)->
					if err then throw err
					console.log results


  # Jmonitor show
	robot.hear /jmshow (.+) (.+)/i, (msg) ->
		host = msg.match[1].trim()
		type = msg.match[2].trim()
		types = ["iostat", "disk", "memory", "load", "replication", "com_status", "threads_status", "slow_query", "tmp_table"]
		if not (type in types or type == "all")
			msg.send "No data-type \"#{type}\" found, ..."
			msg.send "Usage: Jmysql_monitor show hostname (" + types.join('|') + "|all)"
			return false
		if type == "all"
			type = types
		else
			type = [type]
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			host = data[0].host_name
			funcs = []
			for t in type
				funcs.push do(t)->
					(callback)->
						msg.send "Generate graph for #{t} of #{host}, ..."
						logs.push "[INFO] Execute Jmysql_monitor python script for #{host}(#{id})"
						command =  "python ~/.nodebrew/Jmysql_monitor_bot/scripts/python_script/image.py \"#{id}\" \"#{host}\" \"#{t}\""
						command += " | python ~/.nodebrew/Jmysql_monitor_bot/scripts/python_script/upload_s3.py"
						console.log command
						exec command, (error, stdout, stderror)->
							msg.send stdout
							callback()
			async.waterfall funcs, (err, results)->
				if err then throw err
				console.log results

	# Jmysql_monitor monitor status
	robot.hear /Jmysql_monitor monitor status (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchJmonitorCategory msg, (ctrg)->
			data2 =[]
			searchJmonitorHost msg, host, (data2)->
				if (data2.length == 0)
					msg.send "No host \"#{host}\" found, ..."
				else
					target_id = data2[0]['id']
					data3 = []
					searchJmonitorThreshold msg, target_id, (data3)->
						for t in data3
							for c in ctrg
								if (t.category_id == c.id)
									if (t.monitoring == true)
										if (t.value != null)
											msg.send "#{c.name} = #{t.value}  (successful)\n"
										else
											msg.send "#{c.name}  (successful)\n"
									else
										if (t.value != null)
											msg.send "#{c.name} = #{t.value}  (unknown)\n"
										else
											msg.send "#{c.name}  (unknown)\n"

	# Jmysql_monitor monitor status
	robot.hear /jmstat (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchJmonitorCategory msg, (ctrg)->
			data2 =[]
			searchJmonitorHost msg, host, (data2)->
				if (data2.length == 0)
					msg.send "No host \"#{host}\" found, ..."
				else
					target_id = data2[0]['id']
					data3 = []
					searchJmonitorThreshold msg, target_id, (data3)->
						for t in data3
							for c in ctrg
								if (t.category_id == c.id)
									if (t.monitoring == true)
										if (t.value != null)
											msg.send "#{c.name} = #{t.value}  (successful)\n"
										else
											msg.send "#{c.name}  (successful)\n"
									else
										if (t.value != null)
											msg.send "#{c.name} = #{t.value}  (unknown)\n"
										else
											msg.send "#{c.name}  (unknown)\n"

  # Jmysql_monitor monitor list
	robot.hear /Jmysql_monitor monitor list/i, (msg) ->
		searchJmonitorCategory msg, (category)->
			for c in category
				msg.send "#{c.id} = #{c.name}"


  # Jmysql_monitor monitor flag change
	robot.hear /jmflg (.+) (.+) (.+)/i, (msg) ->
		type = ["flg"]
		host = msg.match[1].trim()
		item = msg.match[2].trim()
		target_flg = msg.match[3].trim()
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			host = data[0].host_name
			port = data[0].port_num
			searchJmonitorThresholdId msg, id, host, item, (data1) ->
				thre_id = data1[0].id
				current_flg = data1[0].monitoring
				funcs = []
				for t in type
					funcs.push do(t)->
						(callback)->
							command = "python ~/.nodebrew/Jbot_for_MySQL_operations/scripts/Jmysql_monitor_monitor.py \"#{target_flg}\" \"#{thre_id}\" \"#{current_flg}\" \"#{host}\" \"#{port}\" \"#{item}\""
							console.log command
							exec command, (error, stdout, stderror)->
								msg.send stdout
								callback()
				async.waterfall funcs, (err, results)->
					if err then throw err
					console.log results


  # Jmysql_monitor monitor flag change
	robot.hear /Jmysql_monitor flg (.+) (.+) (.+)/i, (msg) ->
		type = ["flg"]
		host = msg.match[1].trim()
		item = msg.match[2].trim()
		target_flg = msg.match[3].trim()
		searchJmonitorHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			host = data[0].host_name
			port = data[0].port_num
			searchJmonitorThresholdId msg, id, host, item, (data1) ->
				thre_id = data1[0].id
				current_flg = data1[0].monitoring
				funcs = []
				for t in type
					funcs.push do(t)->
						(callback)->
							command = "python ~/.nodebrew/Jbot_for_MySQL_operations/scripts/Jmysql_monitor_monitor.py \"#{target_flg}\" \"#{thre_id}\" \"#{current_flg}\" \"#{host}\" \"#{port}\" \"#{item}\""
							console.log command
							exec command, (error, stdout, stderror)->
								msg.send stdout
								callback()
				async.waterfall funcs, (err, results)->
					if err then throw err
					console.log results
