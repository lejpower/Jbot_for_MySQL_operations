# Description:
#
# Author : Uijun.Lee  
# Date   : 2015/01/13
#

dbq_url= process.env.DBQ_URL
dbq_auth= process.env.DBQ_AUTH

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

　　
	# dbq
	searchDBQHost = (msg, host, callback)->
		url = "#{dbq_url}" + "/admin/instances.json?" + "#{dbq_auth}"
		url += "&name=&host_name=#{host}&port_num=&commit=Search"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchDBQHost----------"

	searchDBQSlave = (msg, id, callback)->
		url = "#{dbq_url}" + "/instances/" + "#{id}" + "/slave_status.json"
		url += "?" + "#{dbq_auth}"
		console.log url
		msg.http(url).get() (err, res, body) ->
			callback JSON.parse(body)
			console.log "-----searchDBQSlave----------"
　　　
  ### Conversation with HUBOT ###

		## ------------------------Juni Editing --------------------------------##

        # help
	robot.hear /dbq help/i, (msg) ->
		msg.send "Usage: dbq slave ${HOSTNAME}"
	
	# dbq slave status
	robot.hear /dbq slave (.+)/i, (msg) ->
		host = msg.match[1].trim()
		searchDBQHost msg, host, (data1)->
			if (data1.length == 0)
				msg.send "No host \"#{host}\" found, ..."
			else
				target_id = data1[0]["instance"]["id"]
				data2 = []
				searchDBQSlave msg, target_id, (data2)->
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

