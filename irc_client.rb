=begin
IRC Client
=end

#IRC Client requrie library
gem "irc-socket"
require 'irc-socket'

#ARGV loop require library
require 'optparse'

# Popen library
require 'open3'

# sqlite library
require 'sqlite3'
require_relative 'create_table'

#default irc server setup
SERVER = "bsd-himrock922.jaist.ac.jp"
PORT = 6667
CHANNEL ="#ikachang"
EOF = "\r\n"
NICK = "himrock922"
USER = "him"
OPTS = {}

class IRC
	include CreateTable
Signal.trap(:INT) {
	@@channel_hash.each_key do |key|
		@@irc.privmsg "#{key}", " DEL-IKAGENT #{@@channel}" 
		@@irc.privmsg "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick}" # send DEL-CHANNEL message (hash table for value delete)
	end
	@@db.execute(@@sql_delete)
	@@db.close
	exit
}
@@hash = {}
@@channel_hash = {}
@@tako_id  = ""
@@tako_mac = ""
@@tako_app = ""

	# while ping_pong and hash table process

	@@ping_pong = Thread::fork do
		Thread::stop
		while msg = @@irc.read

			# server connection confirmation
			if msg.split[0] == 'PING'
				@@irc.pong "#{msg.split[1]}"
				@@ikagent_stable.wakeup
				
			end
			################################

			# if msg.split[1] only process
			####################################################
			####################################################
			case msg.split[1]

			# private message (NEW) for channel name extract
			when '319'
				channel_tmp = msg.split(/\:\@/) # such message to :@ extract 
				channel_hash_tmp = {} # temporary channel table
				channel_hash_tmp.store("#{channel_tmp[1]}", 1)
				@@channel_hash.update(channel_hash_tmp) # channel table update
			##################################################

			# server flooding channel information store for hash table
			when '322'
				@@channel_hash.store("#{msg.split[3]}", "#{msg.split[4]}")
			####################################################

			# channel hash table output
			when '323'
				@@channel_hash.each_key do |key|
					@@irc.privmsg "#{key}", " NEW-CHANNEL #{@@nick} #{@@ip} #{@@channel}" # other ikagent send private message about own information (NEW)
				end

			######################################

			## my channel join user information store hash table
			# join command for usrname extraction	
			when 'JOIN'
				mj_user = msg.split(/\!\~/)
				mj_user[0].slice!(0)
				@@irc.whois "#{mj_user[0]}"
			################################################

			# extraction username for user information store 
			# hash table
			when '338'
				@@hash.store("#{msg.split[3]}", "#{msg.split[4]}")
				if msg.split[3] == @@nick
					@@ikagent_ip = "#{msg.split[4]}"
					@@db.execute("update Ikagent_List set ikagent_addr = ? where ikagent_cha = ?", @@ikagent_ip, @@channel)
				end
				@@ip = "#{msg.split[4]}"
			################################################

			# my channel part user delete for hash table
			when 'PART'
				mp_user = msg.split(/\!\~/)
				mp_user[0].slice!(0)
				@@hash.delete("#{mp_user[0]}")
				@@ikagent_stable.wakeup
			################################################
			end
			################################################
			################################################

			# PRIVMSG process
			################################################
			################################################
			
			# if new ikagent join server session process
			################################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'NEW-CHANNEL'
				@@hash.store("#{msg.split[5]}", "#{msg.split[6]}")
				@@channel_hash.store("#{msg.split[7]}", "1")
				@@channel_hash.each_key do |c_key|
					@@irc.privmsg "#{c_key}", " UPD-IKAGENT #{@@nick} #{@@ip}" # other ikagent private message about own information (UPDATE)
				end
				p "new paramater store!"
				@@ikagent_stable.wakeup
			end
			###############################################

			# if update ikagent message process
			###############################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'UPD-IKAGENT'
				tmp_hash = {} # templary hash table
				tmp_hash.store("#{msg.split[5]}", "#{msg.split[6]}")
				@@hash.update(tmp_hash) # stable hash table update
				p "update paramater!"
				@@ikagent_stable.wakeup
			end
			###############################################

			if msg.split[1] == 'PRIVMSG' && ( msg.split[4] == 'NEW-TAKO' || msg.split[4] == 'UPD-TAKO')
				msg_tmp  = msg.split(/\|\|/)
				channel  = msg.split[5]
				nick     = msg.split[6]
				ip       = msg.split[7]
				tako_id_tmp  = msg_tmp[0].split[8] << "||"
				tako_mac_tmp = msg_tmp[1] << "||"
				tako_app_tmp = msg_tmp[2] << "||"
				count = 0
				while true
					@@db.execute("#{@@sql_select}") do |row|
						if channel == row[0]
							tako_id  = ""
							tako_mac = ""
							tako_app = ""
							@@db.execute("#{@@sql_select} where ikagent_cha = ?", channel) do |row_tmp|
								tako_id  = row_tmp[3] 
								tako_mac = row_tmp[4] 
								tako_app = row_tmp[5] 
							end
							tako_id  << tako_id_tmp
							tako_mac << tako_mac_tmp
							tako_app << tako_app_tmp

							@@db.execute("#{@@sql_update} set tako_id = ?, tako_mac = ?, tako_app = ? where ikagent_cha  = ? ", tako_id, tako_mac, tako_app, channel)
							count = 1
							break
						end
					end
					if count == 0
						@@db.execute("#{@@sql_insert}", channel, nick, ip, tako_id_tmp, tako_mac_tmp, tako_app_tmp)
						break
					else
						break
					end
				end
				@@ikagent_stable.wakeup
				if msg.split[4] == 'NEW-TAKO'
					@@db.execute("#{@@sql_select} where ikagent_cha = ?", @@channel) do |row|
						@@channel_hash.each_key do |key|
							@@irc.privmsg "#{key}", " UPD-TAKO #{@@channel} #{@@nick} #{@@ip} #{row[3]}#{row[4]}#{row[5]}"
						end
					end
				end
			end
			
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'DEL-IKAGENT'
				d_channel = msg.split[5]
				@@db.execute("#{@@sql_delete} where ikagent_cha = ?", d_channel)
			end
					

			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'DEL-TAKO'
				d_channel = msg.split[5]
				d_tako_id = msg.split[6]
				del_id  = ""
				del_mac = ""
				del_app = ""
				@@db.execute("#{@@sql_select} where ikagent_cha = ?", d_channel) do |row|
					del_id_tmp   = row[3].split(/\|\|/)
					del_mac_tmp  = row[4].split(/\|\|/)
					del_app_tmp  = row[5].split(/\|\|/)
					i = 0
					while del_id_tmp[i] != nil
						if del_id_tmp[i] == d_tako_id
							i += 1
							next
						end
						del_id  << del_id_tmp[i]  << "||"
						del_mac << del_mac_tmp[i] << "||"
						del_app << del_app_tmp[i] << "||"
						i += 1
					end
				end
				@@db.execute("#{@@sql_update} set tako_id = ?, tako_mac = ?, tako_app = ? where ikagent_cha = ?", del_id, del_mac, del_app, d_channel)
				@@ikagent_stable.wakeup
			end
				

			# if disconnect ikagent server session process
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'DEL-CHANNEL'
				@@channel_hash.delete("#{msg.split[5]}") # channel table disconnect ikagent delete

				@@hash.delete("#{msg.split[6]}") # hash table disconnect ikagent delete
				# such table output
				p "delete complete"
				@@ikagent_stable.wakeup
			end
 			###############################################

			###############################################
			###############################################

			# message output
			p msg
		end
	end
	#########################################
	#########################################
	#########################################

	# Communication between nodes for process
	#########################################	
	@@pwn_poxpr = Thread::fork do
		Thread::stop
			# Collaboration with communication between nodes program
			poxpr_input, poxpr_output = Open3.popen3('./poxpr -c 1 -X')
			# Collaboration program stdout
			poxpr_output.each do | core_output |
				poxpr_ex =  core_output.chomp
				p poxpr_ex
				## NEW or DEL or UPD process
				case poxpr_ex.split[0]
				# when poxpr output 'NEW'
				when 'NEW'
					tako_id_tmp  = ""
					tako_mac_tmp = ""
					tako_app_tmp = ""
					tako_id_tmp.concat "#{poxpr_ex.split[1]}|" # tako_id store
					tako_mac_tmp.concat "#{poxpr_ex.split[2]}|" # tako_mac store
					i = 3 
					
					# tako_app ptocess
					while poxpr_ex.split[i] != nil
						tako_app_tmp.concat "#{poxpr_ex.split[i]}|" # tako_app store
						i += 1
					end
					###############################
					tako_id_tmp.concat  "|"
					tako_mac_tmp.concat "|"
					tako_app_tmp.concat "|" # such tako_app split '||'
					

					@@tako_id  << tako_id_tmp   # tako_id stable << tako_id temporary
					@@tako_mac << tako_mac_tmp  # tako_mac stable << tako_mac temporary
					@@tako_app << tako_app_tmp # tako_app stable << tako_app temporary
					@@db.execute("#{@@sql_update} set tako_id = ?, tako_mac = ?, tako_app = ? where ikagent_cha = ?", @@tako_id, @@tako_mac, @@tako_app, @@channel) # sql database update such tako paramater
					
					# sql database output
					@@db.execute("#{@@sql_select}") do |row|
							p row
					end
					######################
					
					# such channel NEW data send
					@@channel_hash.each_key do |key|
						@@irc.privmsg "#{key}", " NEW-TAKO #{@@channel} #{@@nick} #{@@ip} #{tako_id_tmp}#{tako_mac_tmp}#{tako_app_tmp}"
					end
					################################

				########################################
		
				# when poxpr output 'DEL'
				when 'DEL'
					delete_poxpr = poxpr_ex.split[1] # delete tako_id store
					# setting
					i = 0
					tako_delete_id  = ""
					tako_delete_id_tmp = @@tako_id.split(/\|\|/)
					tako_delete_mac = ""
					tako_delete_mac_tmp = @@tako_mac.split(/\|\|/)
					tako_delete_app = ""
					tako_delete_app_tmp = @@tako_app.split(/\|\|/)
					##############################
					# while loop until reach delete tako_id
					while tako_delete_id_tmp[i] != nil
						# if reach delete tako_id 
						if tako_delete_id_tmp[i] == delete_poxpr
							i += 1
							next
						end
						################################

						tako_delete_id  << tako_delete_id_tmp[i]  << "||" # other tako_id store than tako_id deleted
						tako_delete_mac << tako_delete_mac_tmp[i] << "||" # other tako_mac store than tako_id deleted 
						tako_delete_app << tako_delete_app_tmp[i] << "||" # other tako_app store than tako_id deleted
						i += 1
					end
					######################################
					@@tako_id  = tako_delete_id  # update tako_id store
					@@tako_mac = tako_delete_mac # update tako_mac store
					@@tako_app = tako_delete_app # update tako_pp store
					@@db.execute("#{@@sql_update} set tako_id = ?, tako_mac = ?, tako_app = ? where ikagent_cha = ?", @@tako_id, @@tako_mac, @@tako_app, @@channel) # sql data update
						
					# sql output
					@@db.execute("#{@@sql_select}") do |row|
						p row
					end
					########################################
					del_msg = ""
					del_msg = delete_poxpr
					p del_msg
					# such channel del tako_id send
					@@channel_hash.each_key do |key|
						@@irc.privmsg "#{key}", " DEL-TAKO #{@@channel} #{del_msg}"
					end
					########################################
				end
		end
		#########################################
		
		#########################################
		#########################################
	end
	##################################################
			
	# thread write process
	#################################################
	@@writen = Thread::fork do
		Thread::stop
		while input = gets.chomp # wait stdin
			if /exit/i =~ input # program exit process
				@@channel_hash.each_key do |key|
					@@irc.privmsg "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick}" # send DEL-CHANNEL message (hash table for value delete)
					@@db.execute(@@sql_delete)
					@@db.close
				end
				exit
			else
				next # other continue
			end
		end
	end
	##########################################################

	# ikagent list store process
	##########################################################
	@@ikagent_stable = Thread::fork do
		Thread::stop
		while true
			sleep # sleep until wakeup
				print EOF	
				p "channel table"
				@@channel_hash.each_key do |key|
					p "#{key}"
				end
				print EOF
				p "hash table"
				@@hash.each do |key, val|
					p "#{key} #{val}"
				end
				print EOF
				p "sql table"
				@@db.execute("#{@@sql_select}") do |row|
					p row
				end
			end		
		end
	##########################################################

	# start
	##########################################################
	def initialize
		OptionParser::new do |opt|
			begin
				# program name output
				opt.program_name = File.basename($0)
				opt.version = '0.0.1'
				#####################	

				# Usage output		
				opt.banner = "Usage: #{opt.program_name} [options] options support command input"
				#####################

				# Examples output
				opt.separator ''
				opt.separator 'Examples:'
				opt.separator "    % #{opt.program_name} -s example.jp -p 6667 -n himrock922 -u himrock -c ikachang"
				#####################
			
				# Specific Options Usage output
				opt.separator ''
				opt.separator 'Specific options:'
				opt.on('-s SERVER', '--server', 'server')    {|v| OPTS[:s] = v}
				opt.on('-p PORT', '--port', 'port')          {|v| OPTS[:p] = v}
				opt.on('-n NICK', '--nick', 'nick')          {|v| OPTS[:n] = v}
				opt.on('-u USER', '--user', 'user')          {|v| OPTS[:u] = v}
				opt.on('-c CHANNEL', '--channel', 'channel') {|v| OPTS[:c] = v}
				############################################
			
				# Options Usage output
				opt.separator ''
				opt.separator 'Common options:'

				opt.on_tail('-h', '--help', 'show this help 
				     message end exit') do
					puts opt
					exit
				end
				############################################
	
				opt.parse!(ARGV)
				rescue => e
					puts "ERROR: #{e}.\nSee #{opt}"
					exit
				end
			end
	
		#Each option store
		if OPTS[:s] then @server = OPTS[:s] else @server = SERVER end
		if OPTS[:p] then @port = OPTS[:p] else @port = PORT end
		if OPTS[:n] then @@nick = OPTS[:n] else @@nick = NICK end
		if OPTS[:u] then @user = OPTS[:u] else @user = USER end
		if OPTS[:c] then @@channel = "#" + OPTS[:c] else @@channel = CHANNEL end
		################################################################

		# SQLite3 process
		@@db = SQLite3::Database::new("ikagent_list.db") # Database open

		table = @@db.execute("select tbl_name from sqlite_master where type == 'table' ").flatten # Table name read

		# if Nothing Table create Table
		if table[0] == nil
			@@db.execute(create_ikable)
		end
		sql_command # sql_coomand summary method
		@@db.execute(@@sql_insert, @@channel, @@nick, "", "", "", "")
		##################################

		# such paramater output
		puts @server, @port, @@nick, @user, @@channel
		
		# irc socket create
		@@irc = IRCSocket.new(@server, @port)
		# irc server connect
		@@irc.connect

		# connection process
		if @@irc.connected?
			@@irc.nick "#{@@nick}" # nickname decide
			@@irc.user "#{@user}", 0, "*", "I am #{@user}" # hello message 
			@@irc.join "#{@@channel}" # channel name decide
			@@irc.mode "#{@@channel}", "-n" # mode change
		end
		###################################################

		# ikagent start
		#######################
		######################

		# thread run
		#######################
		@@irc.whois @@nick
		@@irc.list # channel list output
		@@ping_pong.run # server message read process
		@@writen.run # ikagent message write process
		@@pwn_poxpr.run # poxpr process
		@@ikagent_stable.run # ikagent_stable process
		#######################
		
		# such thread join
		########################
		@@writen.join
		@@ping_pong.join
		@@pwn_poxpr.join
		@@ikagent_stable.join
		########################
		
		########################
		########################
		end

		# sql_command summary store process
		def sql_command
			@@sql_insert = insert_ikable
			@@sql_delete = delete_ikable
			@@sql_update = update_ikable
			@@sql_select = select_ikable
		end
		####################################
	end
IRC::new
