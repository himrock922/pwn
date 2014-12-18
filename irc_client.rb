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

require 'timeout'

require_relative 'create_takoble'
require_relative 'create_appble'
require_relative 'create_cache'
require_relative 'create_appnum'
require_relative 'create_comnum'
require_relative 'create_value'
require_relative 'create_number'
require_relative 'cache_tako'
require_relative 'cache_select_one'
require_relative 'join_table'
require_relative 'random_tako'
require_relative 'random_tako_query'
require_relative 'random_tako_reply'
require_relative 'extact_match'
require_relative 'extact_match_query'
require_relative 'extact_match_reply'
require_relative 'common_app'
require_relative 'common_app_query'
require_relative 'common_app_reply'

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
	include CreateAppNum
	include CreateComNum
	include CreateValue
	include CreateNumber
	include JoinTable
	include CreateCache
	include CacheTako
	include CacheSelectOne
	extend  RandomTako
	extend  RandomTakoQuery
	extend  RandomTakoReply
	extend  ExtactMatch
	extend  ExtactMatchQuery
	extend  ExtactMatchReply
	extend  CommonApp
	extend  CommonAppQuery
	extend  CommonAppReply
Signal.trap(:INT) {
	@@channel_hash.each_key do |key|
		if @@channel == nil
			@@irc.notice "#{key}", " DEL-IKAGENT #{@@nick} #{@@ip}"
		elsif @@channel != nil
			@@irc.notice "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick} #{@@ip}" # send DEL-CHANNEL message (hash table for value delete)
		end
	end
	@@db.execute(@@tako_delete)
	@@db.execute(@@app_delete)
	@@db.execute(@@cac_delete)
	@@db.execute(@@cat_delete)
	@@db.execute(@@cso_delete)
	@@db.execute(@@com_delete)
	@@db.execute(@@val_delete)
	@@db.execute("vacuum")
	@@db.close
	@@input.close
	exit
}
@@channel_stable = Array.new
@@channel_hash = {}
@@tako_id  = ""
@@tako_mac = ""
@@tako_app = ""
@@start = 0
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
					print "#{row[0]}, #{row[1]}, #{row[2]}\n"
				end

				if @@channel != nil
					@@channel_hash.each_key do |key|
						if @@channel == key
							next
						end
						@@irc.notice "#{key}", " UPD-CHANNEL #{@@channel} #{@@channel_join}"
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
					msg = " NEW-IKAGENT #{@@nick} #{@@ip}"
					for key in @@channel_stable do
						@@irc.privmsg "#{key}", "#{msg}"
					end
					@@timeout.wakeup
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
							@@irc.notice "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick}" # send DEL-CHANNEL message (hash table for value delete)	
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
					next
				end
				################################################

				# no operator process
				if @@nick == mp_user[0]
					@@channel_stable.delete("#{mp_cha}") # when own part, channel_stable hash delete
				end
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
					@@irc.notice "#{key}", " UPD-CHANNEL #{@@channel} #{@@channel_join}" # other ikagent private message about own information (UPDATE)
				end
				p "new channel store!"
			end
			###############################################

			# if upd channel send process
			########################################################
			if msg.split[1] == 'NOTICE' && msg.split[4] == 'UPD-CHANNEL'
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
			if msg.split[1] == 'NOTICE' && msg.split[4] == 'DEL-CHANNEL'
				# setting
				d_cha  = msg.split[5]
				d_nick = msg.split[6]
				d_ip   = msg.split[7] 
				#####################

				@@channel_hash.delete("#{d_cha}") # channel table disconnect ikagent delete
				d_nick.encode!("UTF-8")
				d_ip.encode!("UTF-8")
				@@db.execute("#{@@cac_delete} where ikagent_id = ? and ikagent_ip = ?", d_nick, d_ip)
				# such table output
				p "delete complete"
			end
 			###############################################

			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'NEW-IKAGENT'
				@@mutex.lock
				# setting
				ikagent = msg.split[5]
				ip   = msg.split[6]
				
				ikagent.encode!("UTF-8")
				ip.encode!("UTF-8")
				
				row = @@db.execute("#{@@cac_select} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)

				if row.empty? == true
					@@db.execute(@@cac_insert, ikagent, ip)
				else
					@@db.execute("#{@@cac_update} set ikagent_id = ?, ikagent_ip = ? , update_date = (datetime('now', 'localtime')) where ikagent_id = ? or ikagent_ip = ? ", ikagent, ip, ikagent, ip)
				end

				own_tako = ""
				own_mac  = ""
				own_app  = ""
				@@db.execute(@@tako_select) do |row|
					break if row.empty? == true
					own_tako = row[0]
					own_mac  = row[1]
					@@db.execute("select tako_app from APP_List where tako_id = ?", own_tako) do |sow|
						own_app += "#{sow[0]} "
					end
					msg = " NEW-TAKO #{@@nick} #{@@ip} #{own_tako} #{own_mac} #{own_app}"
					@@irc.notice "#{ikagent}", "#{msg}"
				end
				@@timeout.wakeup
				@@mutex.unlock
			end
				
				
			# if disconnect ikagent (no operator) session process
			##########################################################
			if msg.split[1] == 'NOTICE' && msg.split[4] == 'DEL-IKAGENT'
				# setting
				d_nick = msg.split[5]
				d_ip   = msg.split[6]

				d_nick.encode!("UTF-8")
				d_ip.encode!("UTF-8")
				@@db.execute("#{@@cac_delete} where ikagent_id = ? and ikagent_ip = ?", d_nick, d_ip)
				# such table output
				p "delete complete"
			end
 			###############################################
				

			# query of choose algorithm process
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'QUERY'
				s_app  = ""
				algo   = msg.split[5]
				s_nick = msg.split[6]
				@@mutex.lock
				case algo
				when 'RANDOM_TAKO'
					s_app = msg.split[7]
					s_app.encode!("UTF-8")
					IRC::random_tako_reply(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@ip, s_nick, s_app)  
				when 'COMMON_APP'
					s_app_tmp = msg 
					i = 7
					while s_app_tmp.split[i] != nil
						s_app += "#{s_app_tmp.split[i]} "
						i += 1
					end
					s_app.encode!("UTF-8")
					IRC::common_app_reply(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@ip, s_nick, s_app)
				when 'BEST_MATCH'
					i = 7
					while msg.split[i] != nil
						s_app += "#{msg.split[i]} "
						i += 1
					end
					s_app.encode!("UTF-8")
					IRC::extact_match_reply(@@irc, @@db, @@app_select, @@apn_select, @@tako_select, @@nick, @@ip, s_nick, s_app)
				end
				@@mutex.unlock
			end
			########################################################

			# update of select algorithm process
			if msg.split[1] == 'NOTICE' && msg.split[4] == 'REPLY'
				@@timeout.wakeup
				@@mutex.lock
				algo = msg.split[5]
				ikagent = msg.split[6]
				ikagent.encode!("UTF-8")
				ip = msg.split[7]
				ip.encode!("UTF-8")
				case algo
				when 'RANDOM_TAKO'
					tako_id  = msg.split[8]
					tako_mac = msg.split[9]
					tako_app = msg.split[10]
					tako_id.encode!("UTF-8")
					tako_mac.encode!("UTF-8")
					tako_app.encode!("UTF-8")
					line = @@output.gets.chomp
					if (line == "\"Timeout!\"")
						print EOF
						p "*************************"
						p "****party tako fixed!****"
						p "*************************" 
						@@input.puts "#{ikagent} #{ip} #{tako_id} #{tako_mac} #{tako_app}"
						print "#{ikagent} #{ip} #{tako_id} #{tako_mac} #{tako_app}\n"
					else
						row = @@db.execute("#{@@cac_select} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)
						if row.empty? == false
							@@db.execute("#{@@cac_update} set ikagent_id = ?, ikagent_ip = ? , update_date = (datetime('now', 'localtime')) where ikagent_id = ? or ikagent_ip = ? ", ikagent, ip, ikagent, ip)
							sow = @@db.execute("#{@@cat_select} where tako_id = ?", tako_id)
							if sow.empty? != true
								@@db.execute(@@cso_insert, tako_id, tako_app)
							else
								@@db.execute(@@cat_insert, ikagent, tako_id, tako_mac)
								@@db.execute(@@cso_insert, tako_id, tako_app)
							end
							p "update complete!"
						else
							@@db.execute(@@cac_insert, ikagent, ip)
							@@db.execute(@@cat_insert, ikagent, tako_id, tako_mac)
							@@db.execute(@@cso_insert, tako_id, tako_app)
							p "insert complete!"
						end
					end
				when 'COMMON_APP'
					value = msg.split[8].to_i
					line = @@output.gets.chomp
					if (line == "\"Timeout!\"")
						print EOF
						p "*************************"
						p "****party tako fixed!****"
						p "*************************" 
						@@input.puts "#{ikagent} #{ip}"
						print "#{ikagent} #{ip} #{value}\n"
					else
						row = @@db.execute("#{@@cac_select} where ikanget_id = ? or ikagent_ip = ?", ikagent, ip)
						if row.empty? == false
							@@db.execute("#{@@cac_update} set ikagent_id = ?, ikagent_ip = ? , update_date = (datetime('now', 'localtime')) where ikagent_id or ikagent_ip = ?", ikagent, ip, ikagent, ip)
							sow = @@db.execute("#{@@com_select} where ikagent_id = ?", ikagent)
							if sow.empty? != true
								@@db.execute("#{@@com_update} set app_num = ?, where ikagent_id = ?", value, ikagent)
							else
								@@db.execute(@@com_insert, ikagent, value)
							end
							p "update complete!"
						else
							@@db.execute(@@cac_insert, ikagent, ip)
							@@db.execute(@@com_insert, ikagent, value)
							p "insert complete!"
						end
					end

				when 'BEST_MATCH'				
					tako_id  = msg.split[8]
					tako_mac = msg.split[9] 
					own_tako = @@tako_id
					tako_id.encode!("UTF-8")
					tako_mac.encode!("UTF-8")
					own_tako.encode!("UTF-8")
					line = @@output.gets.chomp
					if (line == "\"Timeout!\"")
						print EOF
						p "*************************"
						p "****party tako fixed!****"
						p "*************************" 
						@@input.puts "#{ikagent} #{ip} #{tako_id} #{tako_mac}"
						print "#{ikagent} #{ip} #{tako_id} #{tako_mac}\n"
					else
						row = @@db.execute("#{@@cac_select} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)
						if row.empty? == false
							@@db.execute("#{@@cac_update} set ikagent_id = ?, ikagent_ip = ?, update_date = (datetime('now', 'localtime')) where ikagent_ip = ?", ikagent, ip, ikagent, ip)
							sow = @@db.execute("#{@@cat_select} where tako_id = ?", tako_id)
							if sow.empty? != true
								@@db.execute(@@cso_insert, tako_id, own_tako)
							else
								@@db.execute(@@cat_insert, ikagent, tako_id, tako_mac)
								@@db.execute(@@cso_insert, tako_id, own_tako)
							end
							p "update complete!"
						else
							@@db.execute(@@cac_insert, ikagent, ip)
							@@db.execute(@@cat_insert, ikagent, tako_id, tako_mac)
							@@db.execute(@@cso_insert, tako_id, own_tako)
							p "insert complete!"
						end
					end
				end
				@@mutex.unlock
				@@timeout.wakeup
			end
			########################################################			
			########################################################
			if msg.split[1] == 'NOTICE' && msg.split[4] == 'NEW-TAKO'
				@@timeout.wakeup
				@@mutex.lock
				ikagent  = msg.split[5]
				ip       = msg.split[6]
				tako_id  = msg.split[7]
				tako_mac = msg.split[8]
				ikagent.encode!("UTF-8")
				ip.encode!("UTF-8")
				tako_id.encode!("UTF-8")
				tako_mac.encode!("UTF-8")

				row = @@db.execute("#{@@cac_select} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)
				if row.empty? == false
					@@db.execute("#{@@cac_update} set ikagent_id = ?, ikagent_ip = ?, update_date = (datetime('now', 'localtime')) where ikagent_id or ikagent_ip = ?", ikagent, ip, ikagent, ip)
				else
					@@db.execute(@@cac_insert, ikagent, ip)
				end	
			
				row = @@db.execute("#{@@cat_select} where tako_id = ?", tako_id)
				if row.empty? == true
					@@db.execute(@@cat_insert, ikagent, tako_id, tako_mac)
				else
					@@db.execute("#{@@cso_delete} where tako_id = ?", tako_id)
					@@db.execute("vacuum")
				end
				i = 9
				count = 0
				while msg.split[i] != nil
					tako_app = msg.split[i]
					tako_app.encode!("UTF-8")
					@@db.execute(@@cso_insert, tako_id, tako_app)
					i += 1
					count += 1
				end
				if @@algo == "1" && @@smode == "1"
					IRC::random_tako(@@db, @@input, @@output, @@cso_select)
				elsif @@algo == "2" && @@smode == "1"
					IRC::common_app(@@db, @@cac_select, @@cat_select, @@app_select, @@cso_select, @@val_insert, @@val_update, @@val_select)
				elsif @@algo == "3" && @@smode == "1"
					@@db.execute(@@num_insert, tako_id, count)
					IRC::extact_match(@@db, @@tako_id, @@app_select, @@num_select, @@cso_select)
				end
				@@mutex.unlock
				@@timeout.wakeup
			end	
			########################################################
	
			if msg.split[1] == 'NOTICE' && msg.split[4] == 'DEL-TAKO'
				@@mutex.lock
				ikagent = msg.split[5]
				ip      = msg.split[6]
				tako_id = msg.split[7]
				
				ikagent.encode!("UTF-8")
				ip.encode!("UTF-8")
				tako_id.encode!("UTF-8")
				
				@@db.execute("#{@@cso_delete} where tako_id = ?", tako_id)
				@@db.execute("#{@@cat_delete} where tako_id = ?", tako_id)
				row = @@db.execute("#{@@cat_select} where ikagent_id = ?", ikagent)
				if row.empty? == true
					@@db.execute("#{@@cac_delete} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)
				end
				@@db.execute("vacuum")
				@@mutex.unlock
			end
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
			# Collaboration with communication between nodes program
			# Collaboration program stdout
			@@poxpr_output.each do | core_output |
				@@mutex.lock
				p core_output
				poxpr_ex =  core_output.chomp
				## NEW or DEL or UPD process
				case poxpr_ex.split[0]
				# when poxpr output 'NEW'
				when 'NEW'
					tako_id  = ""
					tako_mac = ""
					tako_app = Array.new
					select_tako = ""
					select_app  = ""
					join_app = ""
					
					
					tako_id  = poxpr_ex.split[1] # tako_id store
					tako_mac = poxpr_ex.split[2] # tako_mac store
					i = 3 
					count = 0
					@@db.execute(@@tako_insert, tako_id, tako_mac) # tako_list database insert
					# tako_app ptocess
					while poxpr_ex.split[i] != nil
						tako_app = poxpr_ex.split[i] # tako_app store
						@@db.execute(@@app_insert, tako_id, tako_app)
						join_app += "#{tako_app} "
						i += 1
						count += 1
					end
					###############################
					p "#{@@sql_column}"
					p "#{@@sql_output}"

					@@db.execute(@@apn_insert, tako_id, count)
					# result output
					@@db.execute(@@sql_join) do |row|
						print "#{row[0]}, #{row[1]}, #{row[2]}\n"
					end
					
					@@tako_id = tako_id

					case @@smode
					when "0"
						msg = ""
						case @@algo
						when "1"
							msg = IRC::random_tako_query(@@irc, @@db, @@cac_select, @@cat_select, @@nick, @@app_select, @@tako_select, @@cso_select, @@input, @@output)
						when "2"
							msg = IRC::common_app_query(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@cac_select, @@com_select, @@input, @@output) 
						when "3"
							msg = IRC::extact_match_query(@@irc, @@db, @@app_select, @@nick, tako_id, @@cso_select, @@apn_select)
						end

						next if msg.empty? == true
						for key in @@channel_stable do
							@@irc.privmsg "#{key}", "#{msg}"
						end
					when "1"
					msg = " NEW-TAKO #{@@nick} #{@@ip} #{tako_id} #{tako_mac} #{join_app}"
					for key in @@channel_stable do 
						@@irc.notice "#{key}", "#{msg}"
					end

					@@timeout.wakeup
					end
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
					count = 0
					# tako_app ptocess
					while poxpr_ex.split[i] != nil
						tako_app = poxpr_ex.split[i] # tako_app store
						@@db.execute("#{@@app_delete} where tako_id = ? and tako_app = ?", tako_id, tako_app)
						i += 1
						count += 1
					end
					@@db.execute("#{@@apn_update} set app_num = app_num - ? where tako_id = ?", count, tako_id)
					@@db.execute("vacuum")
					
					###############################
					p "#{@@sql_column}"
					p "#{@@sql_output}"
					# such channel NEW data send
					@@db.execute(@@sql_join) do |row|
						print "#{row[0]}, #{row[1]}, #{row[2]}\n"
						tako_app += "#{row[2]} "
					end
					if @@smode == "1"
						msg = " NEW-TAKO #{@@nick} #{@@ip} #{tako_id} #{tako_mac} #{tako_app}"
						for key in @@channel_stable do
							@@irc.notice "#{key}", "#{msg}"
						end
						@@timeout.wakeup
					end
					
				###############################################	
				when 'DEL'
					# setting
					tako_id = ""
					tako_id = poxpr_ex.split[1] # delete tako_id store
					####################################
					@@db.execute("#{@@tako_delete} where tako_id = ?", tako_id)
					@@db.execute("#{@@app_delete}  where tako_id  = ?", tako_id)
					@@db.execute("#{@@apn_delete}  where tako_id  = ?", tako_id)
					@@db.execute("vacuum")

					p "#{@@sql_column}"
					p "#{@@sql_output}"
					# such channel NEW data send
					@@db.execute(@@sql_join) do |row|
						print "#{row[0]}, #{row[1]}, #{row[2]}\n"
					end
					if @@smode == "1"
						msg = " DEL-TAKO #{@@nick} #{@@ip} #{tako_id}"
						for key in @@channel_stable do
							@@irc.notice "#{key}", "#{msg}"
						end
					end
					########################################
			end
			########################################################
			@@mutex.unlock
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
						@@irc.notice "#{key}", " DEL-IKAGENT #{@@nick} #{@@ip}" 
					elsif @@channel != nil
						@@irc.notice "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick} #{@@ip}" # send DEL-CHANNEL message (hash table for value delete)
					end
					@@db.execute(@@tako_delete) # data base delete 
					@@db.execute(@@app_delete) # data base delete 
					@@db.execute(@@cac_delete)
					@@db.execute(@@cat_delete)
					@@db.execute(@@cso_delete)
					@@db.execute("vacuum")
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

	@@timeout = Thread::fork do
		Thread::stop
		while true
			sleep
			begin
				timeout(10) {
					while true
						sleep 
					end
				}
			rescue Timeout::Error
				p "Timeout!"
				case @@smode 
				when "0"
				when "1"
					case @@algo
					when "1"
						IRC::random_tako(@@db, @@input, @@output, @@cso_select)
					end
				end
			end
		end
	end
			
				
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
				opt.on('-m', '--smode', 'smode')	     {|v| OPTS[:m] = v}
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
		if OPTS[:s] then @@server = OPTS[:s] else @@server = SERVER end
		if OPTS[:p] then @port = OPTS[:p] else @port = PORT end
		if OPTS[:n] then @@nick = OPTS[:n] else @@nick = NICK end
		if OPTS[:t] then @topic = OPTS[:t] else @topic = nil end
		if OPTS[:c] then @@channel = "#" + OPTS[:c] else @@channel = nil end
		if OPTS[:a] then @@algo = OPTS[:a] else @@algo = ALGO end
		if OPTS[:d] then @@dummy = "1" else @@dummy = "0" end
		if OPTS[:m] then @@smode = "1" else @@smode = "0" end
		################################################################

		# SQLite3 process
		@@db = SQLite3::Database::new("ikagent_list.db") # Database open

		table = @@db.execute("select tbl_name from sqlite_master where type == 'table' ").flatten # Table name read

		# if Nothing Table create Table
		if table[0] == nil
			@@db.execute(create_takoble)
			@@db.execute(create_appble)
			@@db.execute(create_cache)
			@@db.execute(create_cako)
			@@db.execute(create_csone)
			@@db.execute(create_appnum)
			@@db.execute(create_comnum)
			@@db.execute(create_value)
			@@db.execute(create_number)
		end

		sql_command # sql_coomand summary method
		##################################

		# such paramater output
		puts @@server, @port,  @@nick
		puts @@channel if @@channel != nil
		# irc socket create
		@@irc = IRCSocket.new(@@server, @port)
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
		@@input, @@output = Open3.popen3('ruby streetpass.rb')
		@@poxpr_input, @@poxpr_output = Open3.popen3('sh dummytako.sh') if @@dummy == "1"
		@@poxpr_input, @@poxpr_output = Open3.popen3('./poxpr -c 1 -X') if @@dummy == "0"
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
		@@timeout.run
		#######################
		
		# such thread join
		########################
		@@writen.join
		@@ping_pong.join
		@@pwn_poxpr.join
		@@timeout.join
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

			@@cat_insert  = insert_cako
			@@cat_delete  = delete_cako
			@@cat_update  = update_cako
			@@cat_select  = select_cako

			@@cso_insert  = insert_csone
			@@cso_delete  = delete_csone
			@@cso_update  = update_csone
			@@cso_select  = select_csone

			@@apn_insert  = insert_appnum
			@@apn_delete  = delete_appnum
			@@apn_update  = update_appnum
			@@apn_select  = select_appnum

			@@com_insert  = insert_comnum
			@@com_delete  = delete_comnum
			@@com_update  = update_comnum
			@@com_select  = select_comnum
			
			@@val_insert  = insert_value
			@@val_delete  = delete_value
			@@val_update  = update_value
			@@val_select  = select_value

			@@num_insert  = insert_number
			@@num_delete  = delete_number
			@@num_update  = update_number
			@@num_select  = select_number

			@@sql_join    = join_table

			@@sql_column  = "tako_id             tako_mac           tako_app"
			@@sql_output  = "-------------------------------------------------"
		end

		####################################
	end
IRC::new
