# Description:
# 
# Author : Uijun.Lee
# Date   : 2015/01/13
#


donkey_host= process.env.DONKEY_HOST
donkey_team= process.env.DONKEY_TEAM
# almond_auth= process.env.ALMOND_AUTH

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

	# idonkey
	robot.hear /donkey help/i, (msg) ->
		msg.send "Usage: idonkey hostname app|sys"
	
	
	robot.hear /donkey (.+) (app|sys)/i, (msg) ->
		logs.push "[INFO] Start donkey search proess"
		team = msg.match[2] + "_team"
		host = msg.match[1].trim()
		async.waterfall [
			# host
			(callback)->
				logs.push "[INFO] Request for host"
				url = "#{donkey_host}" + host
				msg.http(url).get() (err, res, body) ->
					parseXML body, {}, (err, data)->
						try
							team = data.donkeyinfo.host_list[0].host[0][team][0]
						catch err
							msg.send "/code\n[Error] Target host \"#{host}\" not found"
							throw err
						msg.send "/code\n" + "#{msg.match[2]} team of \"#{host}\" is \"#{team}\", searching emergency contact ..."
						callback err, team
			# team
			(team, callback)->
				logs.push "[INFO] Request for team \"#{team}\""
				url = "#{donkey_team}" + team
				msg.http(url).get() (err, res, body) ->
					parseXML body, {}, (err, results)->
						contacts = []
						try
							results = results.donkeyinfo.team_list[0].team[0]
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
			logs.push "[INFO] End donkey search proess"

