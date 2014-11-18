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
require_relative 'create_takoble'
require_relative 'create_appble'
require_relative 'create_cache'
require_relative 'join_table'
require_relative 'random_tako_query'
require_relative 'random_tako_replay'
require_relative 'common_app_query'
require_relative 'common_app_replay'

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
	include CreateTakoble
	include CreateAppble
	include JoinTable
	include CreateCache
	extend  RandomTakoQuery
	extend  RandomTakoReplay
	extend  CommonAppQuery
	extend  CommonAppReplay
Signal.trap(:INT) {
	@@channel_hash.each_key do |key|
		if @@channel == nil
			@@irc.privmsg "#{key}", " DEL-IKAGENT #{@@nick}"
		elsif @@channel != nil
			@@irc.privmsg "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick}" # send DEL-CHANNEL message (hash table for value delete)
		end
	end
	@@db.execute(@@tako_delete)
	@@db.execute(@@app_delete)
	@@db.close
	exit
}
@@channel_stable = Array.new
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
				server = msg.split[1]
				@@irc.pong "#{server}"
				@@ikagent_stable.wakeup

				IRC::random_tako_query(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@channel_stable) if @@algo == "1"  

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
				# setting
				l_cha  = msg.split[3]
				l_join = msg.split[4]
 				#####################

				# channel hash store
				@@channel_hash.store("#{l_cha}", "#{l_join}")
				#############################################

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
				mj_cha = msg.split[2]
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
					next
				elsif mj_user[0] != @@nick
					next
				end
				#############################################

			################################################

			# extraction username for user information store 
			when '338'
				# setting
				ikagent_nick = msg.split[3]
				@@ip = msg.split[4]
				###########################

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
					end
					########################################
					@@ikagent_stable.wakeup # debug message output
					next
				end
				################################################

				# no operator process
				if @@nick == mp_user[0]
					@@channel_stable.delete("#{mp_cha}") # when own part, channel_stable hash delete
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
				# setting
				n_cha  = msg.split[5]
				n_join = msg.split[6]
				#####################

				@@channel_hash.store("#{n_cha}", "#{n_join}") # own channel hash table store other ikagent of information 
				@@channel_hash.each_key do |key|
					@@irc.privmsg "#{key}", " UPD-CHANNEL #{@@channel} #{@@channel_join}" # other ikagent private message about own information (UPDATE)
				end
				p "new channel store!"
			end
			###############################################

			# if upd channel send process
			########################################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'UPD-CHANNEL'
				# setting
				u_cha  = msg.split[5]
				u_join = msg.split[6]
				##################### 
				@@channel_hash.store("#{u_cha}", "#{u_join}")
				p "upd channel store!"
			end
			########################################################

			# if disconnect ikagent server session process
			########################################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'DEL-CHANNEL'
				# setting
				d_cha  = msg.split[5]
				d_nick = msg.split[6] 
				#####################

				@@channel_hash.delete("#{d_cha}") # channel table disconnect ikagent delete
				# such table output
				p "delete complete"
			end
 			###############################################

			# query of choose algorithm process
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'QUERY'
				s_app  = ""
				algo   = msg.split[5]
				s_nick = msg.split[6]
				case algo
				when 'RANDOM_TAKO'
					s_app = msg.split[7]
					s_app.encode!("UTF-8")
					IRC::random_tako_replay(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@ip, s_nick, s_app)  
				when 'COMMON_APP'
					s_app_tmp = msg 
					i = 7
					while s_app_tmp.split[i] != nil
						s_app += "#{s_app_tmp.split[i]} "
						i += 1
					end
					s_app.encode!("UTF-8")
					IRC::common_app_replay(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@ip, s_nick, s_app)
				end
			end
			########################################################

			# update of select algorithm process
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'REPLAY'
				algo = msg.split[5]
				case algo
				when 'RANDOM_TAKO'
					ikagent  = msg.split[6]
					ip       = msg.split[7]
					tako_id  = msg.split[8]
					app      = msg.split[9]
					print EOF
					p "party tako fixed!"
					p "*****************"
					p "#{ikagent} #{ip} #{tako_id} #{app}"
				when 'COMMON_APP'
					ikagent = msg.split[6]
					ip      = msg.split[7]
					value   = msg.split[8]
					print EOF
					p "*************************"
					p "****party tako fixed!****"
					p "*************************"
					p "#{ikagent} #{ip} #{value}"
				end
			end
			########################################################			
			########################################################
			########################################################
	

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
				poxpr_ex =  core_output.chomp
				## NEW or DEL or UPD process
				case poxpr_ex.split[0]
				# when poxpr output 'NEW'
				when 'NEW'
					tako_id  = ""
					tako_mac = ""
					tako_app = ""
					
					select_tako = ""
					select_app  = ""
					
					tako_id  = poxpr_ex.split[1] # tako_id store
					tako_mac = poxpr_ex.split[2] # tako_mac store
					i = 3 
					
					@@db.execute(@@tako_insert, tako_id, tako_mac) # tako_list database insert
					# tako_app ptocess
					while poxpr_ex.split[i] != nil
						tako_app = poxpr_ex.split[i] # tako_app store
						@@db.execute(@@app_insert, tako_id, tako_app)
						i += 1
					end
					###############################
					p "#{@@sql_column}"
					p "#{@@sql_output}"

					# result output
					@@db.execute(@@sql_join) do |row|
						print "#{row[0]}, #{row[1]}, #{row[3]}\n"
					end

					IRC::random_tako_query(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@channel_stable) if @@algo == "1"  
					IRC::common_app_query(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@channel_stable) if @@algo == "2"
					################################
				########################################
		
				# when poxpr output 'DEL'
				when 'UPD'
					tako_id  = ""
					tako_mac = ""
					tako_app = ""

					tako_id  = poxpr_ex.split[1] # update subject tako_id store
					tako_mac = poxpr_ex.split[2] # tako_mac store
					i = 3 
					# tako_app ptocess
					while poxpr_ex.split[i] != nil
						tako_app = poxpr_ex.split[i] # tako_app store
						@@db.execute(@@app_insert, tako_id, tako_app)
						i += 1
					end
					###############################
					p "#{@@sql_column}"
					p "#{@@sql_output}"
					# such channel NEW data send
					@@db.execute(@@sql_join) do |row|
						print "#{row[0]}, #{row[1]}, #{row[3]}\n"
					end
					IRC::random_tako_query(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@channel_stable) if @@algo == "1"  
					
				###############################################	
				when 'DEL'
					# setting
					tako_id = ""
					tako_id = poxpr_ex.split[1] # delete tako_id store
					####################################
					@@db.execute("#{@@tako_delete} where tako_id = ?", tako_id)
					@@db.execute("#{@@app_delete}  where tako_id  = ?", tako_id)

					p "#{@@sql_column}"
					p "#{@@sql_output}"
					# such channel NEW data send
					@@db.execute(@@sql_join) do |row|
						print "#{row[0]}, #{row[1]}, #{row[3]}\n"
					end
					########################################
			end
			########################################################
		end
		################################################################
	end
	########################################################################
			
	# thread write process
	########################################################################
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
					@@db.execute(@@tako_delete) # data base delete 
					@@db.execute(@@app_delete) # data base delete 
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
					@@algo = "1"
				elsif str[1] != nil
					num = str[1].to_s
					if num == "0"
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
				p "#{@@sql_column}"
				p "#{@@sql_output}"
				# such channel NEW data send
				@@db.execute(@@sql_join) do |row|
					print "#{row[0]}, #{row[1]}, #{row[3]}\n"
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
		if OPTS[:t] then @topic = OPTS[:t] else @topic = nil end
		if OPTS[:c] then @@channel = "#" + OPTS[:c] else @@channel = nil end
		if OPTS[:a] then @@algo = OPTS[:a] else @@algo = ALGO end
		if OPTS[:d] then @@dummy = "1" else @@dummy = "0" end
		################################################################

		# SQLite3 process
		@@db = SQLite3::Database::new("ikagent_list.db") # Database open

		table = @@db.execute("select tbl_name from sqlite_master where type == 'table' ").flatten # Table name read

		# if Nothing Table create Table
		if table[0] == nil
			@@db.execute(create_takoble)
			@@db.execute(create_appble)
			@@db.execute(create_cache)
		end

		sql_command # sql_coomand summary method
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
		@@irc.whois @@nick # store of own information
		###################################################

		# ikagent start
		#######################
		######################
		# thread run
		#######################
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
			@@tako_insert = insert_takoble
			@@tako_delete = delete_takoble
			@@tako_update = update_takoble
			@@tako_select = select_takoble

			@@app_insert  = insert_appble
			@@app_delete  = delete_appble
			@@app_update  = update_appble
			@@app_select  = select_appble

			@@cac_insert  = insert_cache
			@@cac_delete  = delete_cache
			@@cac_update  = update_cache
			@@cac_select  = select_cache

			@@sql_join    = join_table

			@@sql_column  = "tako_id             tako_mac           tako_app"
			@@sql_output  = "-------------------------------------------------"
		end

		####################################
	end
IRC::new
