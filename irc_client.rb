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
require_relative 'random_tako'
require_relative 'common_app_ikagent'

#default irc server setup
SERVER = "bsd-himrock922.jaist.ac.jp"
PORT = 6667
CHANNEL ="#ikachang"
EOF = "\r\n"
NICK = "himrock922"
USER = "him"
ALGO = "1"
OPTS = {}

class IRC
	include CreateTable
	extend  RandomTako
	extend  CommonAppIkagent
Signal.trap(:INT) {
	@@channel_hash.each_key do |key|
		if @@channel == nil
			@@irc.privmsg "#{key}", " DEL-IKAGENT #{@@nick}"
		elsif @@channel != nil
			@@irc.privmsg "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick}" # send DEL-CHANNEL message (hash table for value delete)
		end
	end
	@@db.execute(@@sql_delete)
	@@db.close
	exit
}
@@channel_stable = Array.new
@@hash = {}
@@channel_hash = {}
@@tako_id  = ""
@@tako_mac = ""
@@tako_app = ""
@@channel_join = 0
@@mutex = Mutex::new

	# while ping_pong and hash table process

	@@ping_pong = Thread::fork do
		Thread::stop
		while msg = @@irc.read
			p msg
			# server connection confirmation
			if msg.split[0] == 'PING'
				@@irc.pong "#{msg.split[1]}"
				@@ikagent_stable.wakeup
				IRC::random_tako(@@nick, @@db, @@hash) if @@algo == "1"
				IRC::common_app_ikagent(@@nick, @@db, @@hash) if @@algo == "2"
				if @@channel != nil
					@@channel_hash.each_key do |key|
						next if @@channel == key
						@@irc.privmsg "#{key}", " UPD-CHANNEL #{@@channel} #{@@channel_join}"
					end
				end

			end
			################################

			# if msg.split[1] only process
			####################################################
			####################################################
			case msg.split[1]

			# when server load is heavy, retry process
			when '263'
				random = Random.new
				sleep(random.rand(30..60)) # between 30 ~ 60 times sleep 
				@@irc.list	
			##################################################

			# server flooding channel information store for hash table
			when '322'
				@@channel_hash.store("#{msg.split[3]}", "#{msg.split[4]}")
			
			####################################################

			# channel hash table output
			when '323'
				# when already operator being process
				if @@channel_hash.include?("#{@@channel}") == true
					@@channel = nil # @@channel = nothing
				end				
				################################################

				# when no operator ikagent, already channel join process
				if @@channel == nil
					@@channel_hash.each_key do |key|
						@@irc.join "#{key}"
					end
				end
				################################################

			######################################

			## my channel join user information store hash table
			# join command for usrname extraction	
			when 'JOIN'
				# join channel store
				mj_cha  = msg.split[2]
				mj_cha.slice!(0)
				######################
				
				# join user store
				mj_user = msg.split(/\!\~/)
				mj_user[0].slice!(0)
				###########################

				# when operator, process
				if mj_cha == @@channel && mj_user[0] == @@nick
					@@channel_join += 1
					@@channel_hash.store("#{@@channel}", "#{@@channel_join}")
					@@channel_stable.push("#{@@channel}")
					@@channel_hash.each_key do |key|
						@@irc.privmsg "#{key}", "NEW-CHANNEL #{@@channel} #{@@channel_join}"
					end
					next

				elsif mj_cha == @@channel && mj_user[0] != @@nick
					@@channel_join += 1
					@@channel_hash.store("#{@@channel}", "#{@@channel_join}")
					next
				################################################

				# when no operator process
				elsif mj_user[0] == @@nick
					@@channel_stable.push("#{mj_cha}")
					@@irc.privmsg "#{mj_cha}", " NEW-IKAGENT #{mj_user[0]}"
					next
				elsif mj_user[0] != @@nick
					next
				end
				#############################################

			################################################

			# extraction username for user information store 
			# hash table
			when '338'
				# ikagent information (nick, ip) store
				@@hash.store("#{msg.split[3]}", "#{msg.split[4]}")
				# when own ikagent, database update & own_ip store
				if msg.split[3] == @@nick
					@@ip = "#{msg.split[4]}"
					@@db.execute("update Ikagent_List set ikagent_addr = ? where ikagent_nick = ?", @@ip, @@nick)
				end
				################################################

			################################################

			# my channel part user delete for hash table
			when 'PART'
				# part user store
				mp_user = msg.split(/\!\~/)
				mp_user[0].slice!(0)
				###########################
				mp_cha = msg.split[2] # part channel store


				# only operator process				
				if @@channel == mp_cha
					@@channel_join -= 1 # channel join number reduce
					if @@channel_join == 0 # when zero process
						@@channel_hash.delete("#{@@channel}") # channel delete
						@@channel_hash.each_key do |key|
							@@irc.privmsg "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick}" # send DEL-CHANNEL message (hash table for value delete)	
						end
					########################################

						@@channel_stable.delete("#{@@channel}") # message send hash delete 
						@@channel = nil # channel var delete
					########################################
					else
						# channel hash update
						@@channel_hash.store("#{@@channel}", "#{@@channel_join}")
						@@hash.delete("#{mp_user[0]}") #ikagent information delete
					end
					########################################
					@@ikagent_stable.wakeup # debug message output
					next
				end
				################################################

				# no operator process
				if @@nick == mp_user[0]
					@@channel_stable.delete("#{mp_cha}") # when own part, channel_stable hash delete
				else
					@@hash.delete("#{mp_user[0]}") # other ikagent information delete
				end
				@@ikagent_stable.wakeup # debug message
				################################################

			################################################
			end
			################################################
			################################################

			# PRIVMSG process
			################################################
			################################################
			
			# if new channel send  process
			################################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'NEW-CHANNEL'
				@@channel_hash.store("#{msg.split[5]}", "#{msg.split[6]}") # own channel hash table store other ikagent of information 
				@@channel_hash.each_key do |key|
					@@irc.privmsg "#{key}", " UPD-CHANNEL #{@@channel} #{@@channel_join}" # other ikagent private message about own information (UPDATE)
				end
				p "new channel store!"
			end
			###############################################

			# if upd channel send process
			########################################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'UPD-CHANNEL'
				@@channel_hash.store("#{msg.split[5]}", "#{msg.split[6]}")
				p "upd channel store!"
			end
			########################################################

			# if new ikagent mesage process
			###############################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'NEW-IKAGENT'
				@@irc.whois "#{msg.split[5]}"
				@@channel_hash.each_key do |key|
					@@irc.privmsg "#{key}", " UPD-IKAGENT #{@@nick} #{@@ip}"
				end
				p "new ikagent store!"
			end
			########################################################

			# if update ikagent message process
			###############################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'UPD-IKAGENT'
				tmp_hash = {} # templary hash table
				tmp_hash.store("#{msg.split[5]}", "#{msg.split[6]}")
				@@hash.update(tmp_hash) # stable hash table update
				p "update paramater!"
			end
			###############################################

			# if NEW-TAKO-APP information send
			if msg.split[1] == 'PRIVMSG' &&  msg.split[4] == 'NEW-TAKO' 
				@@mutex.lock

				#setting 
				msg_tmp  = msg.split(/\|\|/)
				nick     = msg.split[5]
				ip       = msg.split[6]
				tako_id_tmp  = msg_tmp[0].split[7] << "||"
				tako_mac_tmp = msg_tmp[1] << "||"
				tako_app_tmp = msg_tmp[2] << "||"
				count = 0
				#########################################
				
				# store loop
				while true
					@@db.execute("#{@@sql_select}") do |row|
						# if present in the database already
						# updating process
						if nick == row[0]
							# setting
							tako_id  = ""
							tako_mac = ""
							tako_app = ""
							############
							
							tako_id  = row[2] 
							tako_mac = row[3] 
							tako_app = row[4] 
							######################
							
							# tako information store
							tako_id  << tako_id_tmp
							tako_mac << tako_mac_tmp
							tako_app << tako_app_tmp
							######################

							# database update
							@@db.execute("#{@@sql_update} set ikagent_addr = ?, tako_id = ?, tako_mac = ?, tako_app = ? where ikagent_nick  = ? ", ip, tako_id, tako_mac, tako_app, nick)
							count = 1
							break
							#######################
						end
						###############################
					end
					#######################################

					# when nothing database in data
					if count == 0
						@@db.execute("#{@@sql_insert}", nick, ip, tako_id_tmp, tako_mac_tmp, tako_app_tmp, 0) # insert
						break
					#######################################

					# else break
					elsif count == 1
						break
					end
					#######################################
				end
				##############################################

				# complete data privmsg other ikagent
				@@db.execute("#{@@sql_select} where ikagent_nick = ?", @@nick) do |row|
					next if row[2].empty? == true
					@@irc.privmsg "#{nick}", " UPD-TAKO #{@@nick} #{@@ip} #{row[2]} #{row[3]} #{row[4]}"
				end
				################################################
				@@mutex.unlock
				IRC::random_tako(@@nick, @@db, @@hash) if @@algo == "1"
				IRC::common_app_ikagent(@@nick, @@db, @@hash) if @@algo == "2"
			end
			########################################################

			# other tako information update process
			#######################################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'UPD-TAKO'
				@@mutex.lock
				# setting
				nick     = msg.split[5]
				ip       = msg.split[6]
				tako_id  = msg.split[7]
				tako_mac = msg.split[8]
				tako_app = msg.split[9]
				count    = 0
				#######################

				# update loop process
				while true
					@@db.execute("#{@@sql_select}") do |row|
						# if present in the database already
						if nick == row[0]
							@@db.execute("#{@@sql_update} set tako_id = ?, tako_mac = ?, tako_app = ? where ikagent_nick  = ? ", tako_id, tako_mac, tako_app, nick)
						# data update
							count = 1
							break
						end
						##############################
					end
					# if nothing data in database
					if count == 0
						@@db.execute("#{@@sql_insert}", nick, ip, tako_id, tako_mac, tako_app, 0) 
						break
					########################################
					else
						break
					end
					########################################
				end
				################################################
				@@mutex.unlock
				IRC::random_tako(@@nick, @@db, @@hash) if @@algo == "1"
				IRC::common_app_ikagent(@@nick, @@db, @@hash) if @@algo == "2"
			end
			########################################################

			# other ikagent dell process
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'DEL-IKAGENT'
				d_nick = msg.split[5]
				@@hash.delete("#{d_nick}")
				@@db.execute("#{@@sql_delete} where ikagent_nick = ?", d_nick)
				p "delete ikagent complete!"
			end
			########################################################
					
			# other tako_app delete process
			#########################################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'DEL-TAKO'
				@@mutex.lock
				# setting
				d_nick = msg.split[5]
				d_tako_id = msg.split[6]
				del_id  = ""
				del_id_tmp = ""
				del_mac = ""
				del_mac_tmp = ""
				del_app = ""
				del_app_tmp = ""
				################################################

				# delete decide tako information store
				@@db.execute("#{@@sql_select}") do |row|
					if d_nick != row[0]
						next
					elsif d_nick == row[0]
						del_id_tmp   = row[2].split(/\|\|/)
						if del_id_tmp == d_tako_id
							break
						end	
						del_mac_tmp  = row[3].split(/\|\|/)
						del_app_tmp  = row[4].split(/\|\|/)
						i = 0
				################################################

				# delete process
					while del_id_tmp[i] != nil
						# if delete tako information reach
						if del_id_tmp[i] == d_tako_id
							i += 1 # no store
							next
						end
						################################

						# other tako information store
						del_id  << del_id_tmp[i]  << "||"
						del_mac << del_mac_tmp[i] << "||"
						del_app << del_app_tmp[i] << "||"
						i += 1
						################################
					end
					########################################
					break
					end
				end
				################################################
				# update
				@@db.execute("#{@@sql_update} set tako_id = ?, tako_mac = ?, tako_app = ? where ikagent_nick = ?", del_id, del_mac, del_app, d_nick)
				@@mutex.unlock
			end
			########################################################
			########################################################
	
			# if disconnect ikagent server session process
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'DEL-CHANNEL'
				# setting
				d_cha  = msg.split[5]
				d_nick = msg.split[6] 
				#####################

				@@channel_hash.delete("#{d_cha}") # channel table disconnect ikagent delete

				@@hash.delete("#{d_nick}") # hash table disconnect ikagent delete
				@@db.execute("#{@@sql_delete} where ikagent_nick = ?", d_nick)
				# such table output
				p "delete complete"
			end
 			###############################################

			###############################################
			###############################################

		end
	end
	#########################################
	#########################################
	#########################################
	
	# Communication between nodes for process
	#########################################	
	@@pwn_poxpr = Thread::fork do
		Thread::stop
			poxpr_input, poxpr_output = Open3.popen3('sh dummytako.sh') if @@dummy == "1"
			poxpr_input, poxpr_output = Open3.popen3('./poxpr -c 1 -X') if @@dummy == "0"
			# Collaboration with communication between nodes program
			# Collaboration program stdout
			poxpr_output.each do | core_output |
				p core_output
				@@mutex.lock
				poxpr_ex =  core_output.chomp
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
					@@db.execute("#{@@sql_update} set tako_id = ?, tako_mac = ?, tako_app = ? where ikagent_nick = ?", @@tako_id, @@tako_mac, @@tako_app, @@nick) # sql database update such tako paramater
					
					
					# such channel NEW data send
					for key in @@channel_stable do
						@@irc.privmsg "#{key}", " NEW-TAKO #{@@nick} #{@@ip} #{tako_id_tmp}#{tako_mac_tmp}#{tako_app_tmp}"
					end
					################################
				########################################
		
				# when poxpr output 'DEL'
				when 'UPD'
					s_tako_id    = ""
					tako_id_tmp  = ""
					tako_mac_tmp = ""
					tako_app_tmp = ""
					upd_id       = ""
					upd_mac      = ""
					upd_app      = ""

					s_tako_id.concat  "#{poxpr_ex.split[1]}"   # update subject tako_id store
					tako_id_tmp.concat  "#{poxpr_ex.split[1]}||" # tako_id store
					tako_mac_tmp.concat "#{poxpr_ex.split[2]}||" # tako_mac store
					i = 3 
					# tako_app ptocess
					while poxpr_ex.split[i] != nil
						tako_app_tmp.concat "#{poxpr_ex.split[i]}|" # tako_app store
						i += 1
					end
					###############################
					tako_app_tmp.concat "|" # such tako_app split '||'
					@@db.execute("#{@@sql_select} where ikagent_nick =?", @@nick) do |row|
						upd_id_tmp   = row[2].split(/\|\|/)
						upd_mac_tmp  = row[3].split(/\|\|/)
						upd_app_tmp  = row[4].split(/\|\|/)
						i = 0

							while upd_id_tmp[i] != nil
								if upd_id_tmp[i] == s_tako_id
									upd_id  << tako_id_tmp
									upd_mac << tako_mac_tmp
									upd_app << tako_app_tmp
									i += 1
								next
								end
							upd_id  << upd_id_tmp[i]  << "||"
							upd_mac << upd_mac_tmp[i] << "||"
							upd_app << upd_app_tmp[i] << "||"
							i += 1
							end
						end
					@@tako_id  = upd_id   # tako_id stable << tako_id temporary
					@@tako_mac = upd_mac  # tako_mac stable << tako_mac temporary
					@@tako_app = upd_app # tako_app stable << tako_app temporary
					@@db.execute("#{@@sql_update} set tako_id = ?, tako_mac = ?, tako_app = ? where ikagent_nick = ?", @@tako_id, @@tako_mac, @@tako_app, @@nick) # sql database update such tako paramater
					
				@@db.execute("#{@@sql_select} where ikagent_nick = ?", @@nick) do |row|
					for key in @@channel_stable do
						@@irc.privmsg "#{key}", " UPD-TAKO #{@@nick} #{@@ip} #{row[2]} #{row[3]} #{row[4]}"
					end
				end
				##########################################################################################
	
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
					@@db.execute("#{@@sql_update} set tako_id = ?, tako_mac = ?, tako_app = ? where ikagent_nick = ?", @@tako_id, @@tako_mac, @@tako_app, @@nick) # sql data update
						
					########################################
					del_msg = ""
					del_msg = delete_poxpr
					# such channel del tako_id send
					for key in @@channel_stable do
						@@irc.privmsg "#{key}", " DEL-TAKO #{@@nick} #{del_msg}"
					end
					########################################
			end
			@@mutex.unlock
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
					if @@channel == nil
						@@irc.privmsg "#{key}", " DEL-IKAGENT #{@@nick}" 
					elsif @@channel != nil
						@@irc.privmsg "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick}" # send DEL-CHANNEL message (hash table for value delete)
					end
					@@db.execute(@@sql_delete) # data base delete 
					@@db.close # database close
				end
				exit
			elsif /join/i =~ input
				str = input.split
				# process own channel opretor
				if @@channel_hash.include?(str[1]) == false && @@channel == nil
					@@channel = str[1]

				end
				###############################
				@@irc.join "#{str[1]}" # channel join
			elsif /part/i =~ input
				str = input.split
				@@irc.part "#{str[1]}" # channel part
			#############################################

			# process only operator 
			elsif /topic/i =~ input && @@channel != nil
				str = input.split
				@@irc.topic "#{@@channel}", "#{str[1]}" # channel topic changes
			elsif /mode/i =~ input && @@channel != nil
				str = input.split
				@@irc.mode "#{@@channel}", "#{str[1]}" # channel mode changes
			########################################################

			# list process
			elsif /list/i =~ input
				str = input.split
				if str[1] == nil
					@@irc.list 
				elsif str[1] != nil
					@@irc.list "#{str[1]}" 
				end

			elsif /algo/i =~ input
				str = input.split
				if str[1] == nil
					@@algo = 1
				elsif str[1] != nil
					num = str[1].to_i
					if num == 0
						p "Please enter a numeric value in the argument!"
						next
					end
					@@algo = num
				end
			########################################################

			# help message stdout
			else
				p "help message"
				p "exit : ikagent exit command"
				p "join [channel name] : channel name join command"
				p "part [channel name] : channel name part command"
				p "topic [channel name] : channel topic changes (but operator can use only)"
				p "mode [channel name] : channel mode changes (but operator can use only)"
				p "list [channel name] : channel list output ( when no channel paramater all channel name output)"
				p "algo [number value] : Ikagent choose algorithm changes"
			########################################################
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
				opt.separator "    % #{opt.program_name} -s example.jp -p 6667 -n himrock922 -c ikachang -a 1 ( 1 or 2)"
				#####################
			
				# Specific Options Usage output
				opt.separator ''
				opt.separator 'Specific options:'
				opt.on('-s SERVER', '--server', 'server')    {|v| OPTS[:s] = v}
				opt.on('-p PORT', '--port', 'port')          {|v| OPTS[:p] = v}
				opt.on('-n NICK', '--nick', 'nick')          {|v| OPTS[:n] = v}
				opt.on('-c CHANNEL', '--channel', 'channel') {|v| OPTS[:c] = v}
				opt.on('-a ALGO', '--algo', 'algo')          {|v| OPTS[:a] = v}
				opt.on('-t TOPIC', '--topic', 'topic')	     {|v| OPTS[:t] = v}
				opt.on('-d', '--dummy', 'dummy')	     {|v| OPTS[:d] = v}
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
		if OPTS[:t] then @topic = OPTS[:u] else @topic = nil end
		if OPTS[:c] then @@channel = "#" + OPTS[:c] else @@channel = nil end
		if OPTS[:a] then @@algo = OPTS[:a] else @@algo = ALGO end
		if OPTS[:d] then @@dummy = "1" else @@dummy = "0" end
		################################################################

		# SQLite3 process
		@@db = SQLite3::Database::new("ikagent_list.db") # Database open

		table = @@db.execute("select tbl_name from sqlite_master where type == 'table' ").flatten # Table name read

		# if Nothing Table create Table
		if table[0] == nil
			@@db.execute(create_ikable)
		end

		sql_command # sql_coomand summary method
		@@db.execute(@@sql_insert, @@nick, "", "", "", "", 0)
		##################################

		# such paramater output
		puts @server, @port,  @@nick
		puts @@channel if @@channel != nil
		
		# irc socket create
		@@irc = IRCSocket.new(@server, @port)
		# irc server connect
		@@irc.connect

		# connection process
		if @@irc.connected?
			@@irc.nick "#{@@nick}" # nickname decide
			@@irc.user "#{@@nick}", 0, "*", "I am #{@@nick}" # user name decide
			@@irc.list # channel list store
			if @@channel != nil
				@@irc.join "#{@@channel}" # channel name decide
				if @topic != nil
					@@irc.topic "#{@@channel}", "#{@topic}" # own channel changes of topic
				end
			end
		end
		###################################################

		# ikagent start
		#######################
		######################
		# thread run
		#######################
		@@irc.whois @@nick # store of own information
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
		private
		def sql_command
			@@sql_insert = insert_ikable
			@@sql_delete = delete_ikable
			@@sql_update = update_ikable
			@@sql_select = select_ikable
		end

		####################################
	end
IRC::new
