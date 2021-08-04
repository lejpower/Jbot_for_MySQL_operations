# Description:
#
# Author : Uijun.Lee  
# Date   : 2015/01/13
#

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

　　
	# db_mng_tool
	searchDB_MNG_TOOLHost = (msg, host, callback)->
		url = "#{db_mng_tool_url}" + "/admin/instances.json?" + "#{db_mng_tool_auth}"
		url += "&name=&host_name=#{host}&port_num=&commit=Search"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchDB_MNG_TOOLHost----------"

	searchDB_MNG_TOOLSlave = (msg, id, callback)->
		url = "#{db_mng_tool_url}" + "/instances/" + "#{id}" + "/slave_status.json"
		url += "?" + "#{db_mng_tool_auth}"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchDB_MNG_TOOLSlave----------"

	searchDB_MNG_TOOLVariable = (msg, id, callback)->
		url = "#{db_mng_tool_url}" + "/instances/" + "#{id}" + "/instance_variable.json"
		url += "?" + "#{db_mng_tool_auth}"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchDB_MNG_TOOLVariable----------"

	searchDB_MNG_TOOLParameter = (msg, parameter, id, callback)->
		url = "#{db_mng_tool_url}" + "/instances/" + "#{id}" + "/instance_variable.json" + "?" + "#{db_mng_tool_auth}"
		url += "&variables_name=#{parameter}&commit=Search"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchDB_MNG_TOOLParameter----------"
　　　
  ### Conversation with HUBOT ###

		## ------------------------Juni Editing --------------------------------##

        # help
	robot.hear /db_mng_tool help/i, (msg) ->
		msg.send "Usage(show information): db_mng_tool (slave | var) ${HOSTNAME}"
		msg.send "Usage(search parameter): db_mng_tool sv ${HOSTNAME} ${PARAMETER}"
		msg.send "Usage(change parameter): db_mng_tool cv ${HOSTNAME} ${PARAMETER} ${VALUE}"
		msg.send "Usage(get db_mng_tool url): db_mng_tool url ${HOSTNAME}"
	
	# db_mng_tool slave status
	robot.hear /db_mng_tool slave (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchDB_MNG_TOOLHost msg, host, (data1)->
			if (data1.length == 0)
				msg.send "No host \"#{host}\" found, ..."
			else
				target_id = data1[0]["instance"]["id"]
				data2 = []
				searchDB_MNG_TOOLSlave msg, target_id, (data2)->
					msg.send "
					Slave_IO_State::: #{data2.slave_status.slave_io_state}\n
					Master_Host::: #{data2.slave_status.master_host}\n
					Master_User::: #{data2.slave_status.master_user}\n
					Master_Port::: #{data2.slave_status.master_port}\n
					Connect_Retry::: #{data2.slave_status.connect_retry}\n
					Master_Log_File::: #{data2.slave_status.master_log_file}\n
					Read_Master_Log_Pos::: #{data2.slave_status.read_master_log_pos}\n
					Relay_Log_File::: #{data2.slave_status.relay_log_file}\n
					Relay_Log_Pos::: #{data2.slave_status.relay_log_pos}\n
					Relay_Master_Log_File::: #{data2.slave_status.relay_master_log_file}\n
					Slave_IO_Running::: #{data2.slave_status.slave_io_running}\n
					Slave_SQL_Running::: #{data2.slave_status.slave_sql_running}\n
					Replicate_Do_DB::: #{data2.slave_status.replicate_do_db}\n
					Replicate_Ignore_DB::: #{data2.slave_status.replicate_ignore_db}\n
					Replicate_Do_Table::: #{data2.slave_status.replicate_do_table}\n
					Replicate_Ignore_Table::: #{data2.slave_status.replicate_ignore_table}\n
					Replicate_Wild_Do_Table::: #{data2.slave_status.replicate_wild_do_table}\n
					Replicate_Wild_Ignore_Table::: #{data2.slave_status.replicate_wild_ignore_table}\n
					Last_Errno::: #{data2.slave_status.last_errno}\n
					Last_Error::: #{data2.slave_status.last_error}\n
					Skip_Counter::: #{data2.slave_status.skip_counter}\n
					Exec_Master_Log_Pos::: #{data2.slave_status.exec_master_log_pos}\n
					Relay_Log_Space::: #{data2.slave_status.relay_log_space}\n
					Until_Condition::: #{data2.slave_status.until_condition}\n
					Until_Log_File::: #{data2.slave_status.until_log_file}\n
					Until_Log_Pos::: #{data2.slave_status.until_log_pos}\n
					Master_SSL_Allowed::: #{data2.slave_status.master_ssl_allowed}\n
					Master_SSL_CA_File::: #{data2.slave_status.master_ssl_ca_file}\n
					Master_SSL_CA_Path::: #{data2.slave_status.master_ssl_ca_path}\n
					Master_SSL_Cert::: #{data2.slave_status.master_ssl_cert}\n
					Master_SSL_Cipher::: #{data2.slave_status.master_ssl_cipher}\n
					Master_SSL_Key::: #{data2.slave_status.master_ssl_key}\n
					Seconds_Behind_Master::: #{data2.slave_status.seconds_behind_master}\n
					Master_SSL_Verify_Server_Cert::: #{data2.slave_status.master_ssl_verify_server_cert}\n
					Last_IO_Errno::: #{data2.slave_status.last_io_errno}\n
					Last_IO_Error::: #{data2.slave_status.last_io_error}\n
					Last_SQL_Errno::: #{data2.slave_status.last_sql_errno}\n
					Last_SQL_Error::: #{data2.slave_status.last_sql_error}\n
					Replicate_Ignore_Server_Ids::: #{data2.slave_status.replicate_ignore_server_ids}\n
					Master_Server_Id::: #{data2.slave_status.master_server_id}\n"

	# db_mng_tool show static variables
	robot.hear /db_mng_tool var (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchDB_MNG_TOOLHost msg, host, (data1)->
			if (data1.length == 0)
				msg.send "No host \"#{host}\" found, ..."
			else
				target_id = data1[0]["instance"]["id"]
				data2 = []
				searchDB_MNG_TOOLVariable msg, target_id, (data2)->
					msg.send "[ #{data2.hostname} : #{data2.port} ]"
					msg.send "binlog_format : #{data2.binlog_format}"
					msg.send "character_set_server : #{data2.character_set_server}"
					msg.send "default_storage_engine : #{data2.default_storage_engine}"
					msg.send "innodb_buffer_pool_size : #{Math.round((data2.innodb_buffer_pool_size/1024/1024/1024)*100)/100} GB"
					msg.send "innodb_flush_log_at_trx_commit : #{data2.innodb_flush_log_at_trx_commit}"
					msg.send "log_slave_updates : #{data2.log_slave_updates}"
					msg.send "long_query_time : #{data2.long_query_time}"
					msg.send "max_connections : #{data2.max_connections}"
					msg.send "query_cache_type : #{data2.query_cache_type}"
					msg.send "read_only : #{data2.read_only}"
					msg.send "server_id : #{data2.server_id}"
					msg.send "tx_isolation : #{data2.tx_isolation}"
					msg.send "version : #{data2.version[0..5]}"
					msg.send "DB_MNG_TOOL URL : #{db_mng_tool_url}/instances/#{target_id}/instance_variable"

	# db_mng_tool search parameter
	robot.hear /db_mng_tool sv (.+) (.+)/i, (msg) ->
		host = msg.match[1].trim()
		parameter = msg.match[2].trim()
		searchDB_MNG_TOOLHost msg, host, (data1) ->
			if (data1.length == 0)
				msg.send "No host \"#{host}\" found, ..."
			else
				target_id = data1[0]["instance"]["id"]
				msg.send "[#{host} : show variables like '%#{parameter}%']"
				searchDB_MNG_TOOLParameter msg, parameter, target_id, (data2) ->
					console.log data2
					if (Object.keys(data2).length == 0 )
						msg.send "No parameter like \"%#{parameter}%\" found, please try other key words of parameter!!!"
						msg.send "Usage: db_mng_tool sv ${HOSTNAME} ${PARAMETER}"
					else
						for key,value of data2
							msg.send "#{key} : #{value}"
						msg.send "DB_MNG_TOOL URL : #{db_mng_tool_url}/instances/#{target_id}/instance_variable?variables_name=#{parameter}"

	# db_mng_tool change parameter
	robot.hear /db_mng_tool cv (.+) (.+) (.+)/i, (msg) ->
		type = ["params"]
		host = msg.match[1].trim()
		item = msg.match[2].trim()
		value = msg.match[3].trim()
		searchDB_MNG_TOOLHost msg, host, (data)->
			if data.length == 0
				msg.send "No host \"#{host}\" found, ..."
			else
				id = data[0]["instance"]["id"]
				host = data[0]["instance"]["host_name"]
				port = data[0]["instance"]["port_num"]
				funcs = []
				for t in type
					funcs.push do(t)->
						(callback)->
							command = "python ~/.nodebrew/Jbot_for_MySQL_operations/scripts/db_mng_tool.py \"#{id}\" \"#{item}\" \"#{value}\" \"#{host}\" \"#{port}\""
							console.log command
							exec command, (error, stdout, stderror)->
								msg.send stdout
								callback()
				async.waterfall funcs, (err, results)->
					if err then throw err
					console.log results

	# db_mng_tool url
	robot.hear /db_mng_tool url (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchDB_MNG_TOOLHost msg, host, (data1) ->
			if (data1.length == 0)
				msg.send "No host \"#{host}\" found, ..."
			else
				target_id = data1[0]["instance"]["id"]
				msg.send "DB_MNG_TOOL URL for #{host} =>\n #{db_mng_tool_url}/instances/#{target_id}"
