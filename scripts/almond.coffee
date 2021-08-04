# Description:
#
# Author : Uijun.Lee  
# Date   : 2015/01/13
#

almond_url= process.env.ALMOND_URL
almond_auth= process.env.ALMOND_AUTH

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
　　
　　
	# almond
	searchAlmondHost = (msg, host, callback)->
		url = "#{almond_url}" + "/instances.json?"
		url += "host_name=#{host}&commit=Search&" + "#{almond_auth}"
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchAlmondHost----------"

	searchAlmondThreshold = (msg, id, callback)->
		url = "#{almond_url}" + "/instances/" + "#{id}" + "/thresholds.json"
		url += "?" + "#{almond_auth}"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchAlmondThreshold----------"

	searchAlmondMember = (msg, id, callback)->
		url = "#{almond_url}" + "/instances/" + "#{id}" + "/members.json"
		url += "?" + "#{almond_auth}"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchAlmondMember----------"

	searchAlmondUser = (msg, callback)->
		url = "#{almond_url}" + "/admin/users.json"
		url += "?" + "#{almond_auth}"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchAlmondUser----------"

	offAlmondMonitor = (msg, id, callback)->
		almond_url = "#{almond_url}" + "/thresholds/" + "#{id}" + "/edit"
		almond_url += "?" + "#{almond_auth}"
		request.post
		  url: '#{almond_url}'
		  json:
			  Monitoring: 1
		, (err, response, body) ->
		#console.log url
		#msg.http(url, {monitoring : 1}).post() (err, res, body) ->
			#callback JSON.parse(body)
		console.log "-----offAlmondMonitor----------"

	searchAlmondCategory = (msg, callback)->
		url = "#{almond_url}" + "/admin/categories.json"
		url += "?" + "#{almond_auth}"
		result = msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchAlmondCategory----------"
　　　
  ### Conversation with HUBOT ###

		## ------------------------Juni Editing --------------------------------##

  # Almond url
	robot.hear /almon off (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchAlmondHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			offAlmondMonitor msg, id, (data)->
				msg.send "successful"


	robot.hear /almond search (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchAlmondHost msg, host, (data)->
			data = "/code" + "\n" + util.inspect data, false, null
			msg.send data

	### editing - juni ###
	robot.hear /almond monitor set (.+) (.+) (.+)/i, (msg) ->
		host = msg.match[1].trim()
		category_num = msg.match[2].trim()
		value = msg.match[3].trim()
		searchAlmondHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			updateAlmondThreshold msg, id, category_num, value, (data2)->
	## ------------------------Juni Editing --------------------------------##

  ## Available
	robot.hear /almond help/i, (msg) ->
		types = ["iostat", "disk", "memory", "load", "replication", "com_status", "threads_status", "slow_query", "tmp_table"]
		msg.send "Usage: almond show(alshow) ${HOSTNAME} (" + types.join('|') + "|all)"
		msg.send "Usage: almond url(alurl) ${HOSTNAME}"
		msg.send "Usage: almond monitor list"
		msg.send "Usage: almond monitor status(almon stat) ${HOSTNAME}"
		msg.send "Usage: almond member (almember) ${HOSTNAME}"
		#msg.send "Usage: almond get alert ${HOSTNAME} "
		
	robot.hear /-help/i, (msg) ->
		types = ["iostat", "disk", "memory", "load", "replication", "com_status", "threads_status", "slow_query", "tmp_table"]
		msg.send "Usage: almond show(alshow) ${HOSTNAME} (" + types.join('|') + "|all)"
		msg.send "Usage: almond url(alurl) ${HOSTNAME}"
		msg.send "Usage: almond monitor list"
		msg.send "Usage: almond monitor status(almon stat) ${HOSTNAME}"
		msg.send "Usage: almond member (almember) ${HOSTNAME}"
		msg.send "Usage: idonkey ${HOSTNAME} apps|sys"
		msg.send "Usage: dbq slave ${HOSTNAME}"
		
  # Almond members
	robot.hear /almond member (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchAlmondHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				#return false
			target_id = data[0].id
			searchAlmondUser msg, (users)->
				member = []
				searchAlmondMember msg, target_id, (members)->
					for member in members
						for user in users
							if (member.user_id == user.id)
								msg.send "#{user.email}"

	  # Almond members
	robot.hear /almember (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchAlmondHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				#return false
			target_id = data[0].id
			searchAlmondUser msg, (users)->
				member = []
				searchAlmondMember msg, target_id, (members)->
					for member in members
						for user in users
							if (member.user_id == user.id)
								msg.send "#{user.email}"

  # Almond url
	robot.hear /almond url (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchAlmondHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			host = data[0].host_name
			url = "#{almond_url}" + "/instances/" + "#{id}" + "?alive=true\n"
			url += "=> for #{host}" + "\n"
			msg.send url

  # Almond url
	robot.hear /alurl (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchAlmondHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
				return false
			id = data[0].id
			host = data[0].host_name
			url = "#{almond_url}" + "/instances/" + "#{id}" + "?alive=true\n"
			url += "=> for #{host}" + "\n"
			msg.send url

  # Almond show
	robot.hear /almond show (.+) (.+)/i, (msg) ->
		host = msg.match[1].trim()
		type = msg.match[2].trim()
		types = ["iostat", "disk", "memory", "load", "replication", "com_status", "threads_status", "slow_query", "tmp_table"]
		if not (type in types or type == "all")
			msg.send "No data-type \"#{type}\" found, ..."
			msg.send "Usage: almond show hostname (" + types.join('|') + "|all)"
			return false
		if type == "all"
			type = types
		else
			type = [type]
		searchAlmondHost msg, host, (data)->
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
						logs.push "[INFO] Execute almond python script for #{host}(#{id})"
						command =  "python ~/.nodebrew/almond_bot/scripts/python_script/image.py \"#{id}\" \"#{host}\" \"#{t}\""
						command += " | python ~/.nodebrew/almond_bot/scripts/python_script/upload_s3.py"
						console.log command
						exec command, (error, stdout, stderror)->
							msg.send stdout
							callback()
			async.waterfall funcs, (err, results)->
				if err then throw err
				console.log results

  # Almond show
	robot.hear /alshow (.+) (.+)/i, (msg) ->
		host = msg.match[1].trim()
		type = msg.match[2].trim()
		types = ["iostat", "disk", "memory", "load", "replication", "com_status", "threads_status", "slow_query", "tmp_table"]
		if not (type in types or type == "all")
			msg.send "No data-type \"#{type}\" found, ..."
			msg.send "Usage: almond show hostname (" + types.join('|') + "|all)"
			return false
		if type == "all"
			type = types
		else
			type = [type]
		searchAlmondHost msg, host, (data)->
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
						logs.push "[INFO] Execute almond python script for #{host}(#{id})"
						command =  "python ~/.nodebrew/almond_bot/scripts/python_script/image.py \"#{id}\" \"#{host}\" \"#{t}\""
						command += " | python ~/.nodebrew/almond_bot/scripts/python_script/upload_s3.py"
						console.log command
						exec command, (error, stdout, stderror)->
							msg.send stdout
							callback()
			async.waterfall funcs, (err, results)->
				if err then throw err
				console.log results

	# almond monitor status
	robot.hear /almond monitor status (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchAlmondCategory msg, (ctrg)->
			data2 =[]
			searchAlmondHost msg, host, (data2)->
				if (data2.length == 0)
					msg.send "No host \"#{host}\" found, ..."
				else
					target_id = data2[0]['id']
					data3 = []
					searchAlmondThreshold msg, target_id, (data3)->
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

	# almond monitor status
	robot.hear /almon stat (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchAlmondCategory msg, (ctrg)->
			data2 =[]
			searchAlmondHost msg, host, (data2)->
				if (data2.length == 0)
					msg.send "No host \"#{host}\" found, ..."
				else
					target_id = data2[0]['id']
					data3 = []
					searchAlmondThreshold msg, target_id, (data3)->
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

  # almond monitor list
	robot.hear /almond monitor list/i, (msg) ->
		searchAlmondCategory msg, (category)->
			for c in category
				msg.send "#{c.id} = #{c.name}"
