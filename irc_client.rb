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
require_relative 'create_appnum'
require_relative 'create_value'
require_relative 'cache_ikagent'
require_relative 'cache_tako'
require_relative 'cache_select_one'
require_relative 'cache_exact'
require_relative 'cache_number'
require_relative 'cache_comnum'
require_relative 'join_table'
require_relative 'random_app'
require_relative 'random_app_query'
require_relative 'random_app_reply'
require_relative 'exact_match'
require_relative 'exact_match_query'
require_relative 'exact_match_reply'
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
	include CacheComNum
	include CreateValue
	include JoinTable
	include CacheIkagent
	include CacheTako
	include CacheSelectOne
	include CacheExact
	include CacheNumber
	extend  RandomApp
	extend  RandomAppQuery
	extend  RandomAppReply
	extend  ExactMatch
	extend  ExactMatchQuery
	extend  ExactMatchReply
	extend  CommonApp
	extend  CommonAppQuery
	extend  CommonAppReply
Signal.trap(:INT) {
	@@channel_stable.each do |key|
		if @@channel.empty? == true
			@@irc.notice "#{key}", " DEL-IKAGENT #{@@nick} #{@@ip}"
		else
			@@irc.notice "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick} #{@@ip}" # send DEL-CHANNEL message (hash table for value delete)
		end
	end
	
	@@channel_hash.each_key do |key|
		if @@channel.empty? == true
			@@irc.notice "#{key}", " DEL-IKAGENT #{@@nick} #{@@ip}"
		else
			@@irc.notice "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick} #{@@ip}" # send DEL-CHANNEL message (hash table for value delete)
		end
	end

	@@channel_key.each do |key|
		if @@channel.empty? == true
			@@irc.notice "#{key}", " DEL-IKAGENT #{@@nick} #{@@ip}"
		else
			@@irc.notice "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick} #{@@ip}" # send DEL-CHANNEL message (hash table for value delete)
		end
	end

        @@db.transaction
	@@db.execute(@@tako_delete)
	@@db.execute(@@app_delete)
	@@db.execute(@@cac_delete)
	@@db.execute(@@cat_delete)
	@@db.execute(@@cso_delete)
	@@db.execute(@@com_delete)
	@@db.execute(@@val_delete)
	@@db.commit
	@@db.execute("vacuum")
	@@db.close
	@@input.close
	exit
}
@@channel_stable = Array.new
@@channel_key = Array.new
@@key_ikagent = Array.new
@@channel_hash = {}
@@share_hash = {}
@@tako_id  = ""
@@tako_mac = ""
@@tako_app = ""
@@n_operator = ""
@@p_operator = ""
@@interval = 0
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
				@@irc.pong "#{server}" # server connection state

				# such channel output
				print EOF	
				p "channel table"
				@@channel_hash.each_key do |key|
					p "#{key}"
				end
				@@channel_stable.each do |key|
					p "#{key}"
				end
				@@channel_key.each do |key|
					p "#{key}"
				end
				print EOF
				###############################

				# sql data output
				p "#{@@sql_column}"
				p "#{@@sql_output}"
				@@db.execute(@@sql_join) do |row|
					print "#{row[0]}, #{row[1]}, #{row[2]}\n"
				end
				################################################

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
					@@irc.join "#{@@channel}"
					@@channel_stable.push("#{@@channel}")
					@@channel_key.push("#{@@channel}")
					@@channel = "" # @@channel = nothing
					next
				end

				################################################

				# when no operator ikagent, already channel join process
				if @@channel.empty? == true
					i = 0
					@@channel_hash.sort {|(k1, v1), (k2, v2) | v2 <=> v1}
					@@channel_hash.each do |key, value|
						print key + "=>" , value
						print EOF
						i += 1
						next if i > 2
						@@irc.join "#{key}"
						@@channel_stable.push("#{key}") if @@layer == "none"
					end

				elsif @@channel.empty? == false
					@@irc.join "#{@@channel}"
					@@channel_hash.store("#{@@channel}", 1)
					@@channel_stable.push("#{@@channel}")
					@@channel_key.push("#{@@channel}")
					if @@topic.empty? == false
						@@irc.topic "#{@@channel}", "#{@@topic}"
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

				if @@n_operator == mj_user[0]
					@@irc.mode "#{mj_cha}", "+o #{mj_user[0]}"
					@@n_operator = ""
					@@irc.mode "#{mj_cha}", "-o #{@@nick}"
				end 
				# when operator, process
				#if @@channel.empty? == false && mj_user[0] == @@nick
				#	@@channel_join += 1
				#	@@channel_hash.store("#{@@channel}", "#{@@channel_join}")
						
				#	@@channel_stable.push("#{@@channel}")
				#	@@channel_hash.each_key do |key|
				#		@@irc.privmsg "#{key}", "NEW-CHANNEL #{@@channel} #{@@channel_join}"
				#	end
				#	next

				#elsif @@channel.empty? == false && mj_user[0] != @@nick
				#	@@channel_join += 1
				#	@@n_operator = mj_user[0]
				#	@@channel_hash.store("#{@@channel}", "#{@@channel_join}")
				#	next
				################################################

				# when no operator process
				#elsif @@channel.empty? == true
				#	@@channel_stable.push("#{mj_cha}")
					#msg = " NEW-IKAGENT #{@@nick} #{@@ip}"
					#for key in @@channel_stable do
					#	@@irc.privmsg "#{key}", "#{msg}"
					#end
					#@@timeout.wakeup
				#	next
				#end
				#############################################

			################################################

			# extraction username for user information store 
			when '338'
				# setting
				ikagent_nick = msg.split[3]
				@@ip = msg.split[4]
				###########################

			################################################

			# invite channel process
			when 'INVITE'
				channel = msg.split[3]
				channel.slice!(0)
				@@irc.join "#{channel}"
				@@channel_key.push("#{channel}")
				
			# my channel part user delete for hash table
			when 'PART'
				# part user store
				mp_user = msg.split(/\!\~/)
				mp_user[0].slice!(0)
				###########################
				mp_cha = msg.split[2] # part channel store


				# only operator process				
				if @@channel == mp_cha
					#@@channel_join -= 1 # channel join number reduce
					#if @@channel_join == 0 # when zero process
						@@channel_hash.delete("#{@@channel}") # channel delete
						#@@channel_hash.each_key do |key|
						#	@@irc.notice "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick}" # send DEL-CHANNEL message (hash table for value delete)	
						#end
					########################################

						@@channel_stable.delete("#{@@channel}") # message send hash delete 
						@@channel_key.delete("#{@@channel}")
						@@channel = "" # channel var delete
					########################################
					#else
						# channel hash update
						#@@channel_hash.store("#{@@channel}", "#{@@channel_join}")
					#end
					########################################
					next
				end
				################################################

				# no operator process
				if @@nick == mp_user[0]
					@@channel_stable.delete("#{mp_cha}") # when own part, channel_stable hash delete
					@@channel_key.delete("#{mp_cha}") # when own part, channel_stable hash delete
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
			#if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'NEW-CHANNEL'
				# setting
			#	n_cha  = msg.split[5]
			#	n_join = msg.split[6]
				#####################

			#	@@channel_hash.store("#{n_cha}", "#{n_join}") # own channel hash table store other ikagent of information 
			#	@@channel_hash.each_key do |key|
			#		@@irc.notice "#{key}", " UPD-CHANNEL #{@@channel} #{@@channel_join}" # other ikagent private message about own information (UPDATE)
			#	end
			#	p "new channel store!"
			#end
			###############################################

			# if upd channel send process
			########################################################
			#if msg.split[1] == 'NOTICE' && msg.split[4] == 'UPD-CHANNEL'
				# setting
			#	u_cha  = msg.split[5]
			#	u_join = msg.split[6]
				##################### 
			#	@@channel_hash.store("#{u_cha}", "#{u_join}")
			#	p "upd channel store!"
			#end
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
				@@channel_stable.delete("#{d_cha}") # channel table disconnect ikagent delete
				@@channel_key.delete("#{d_cha}") # channel table disconnect ikagent delete
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
				@@db.transaction	
				row = @@db.execute("#{@@cac_select} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)

				if row.empty? == true
					@@db.execute(@@cac_insert, ikagent, ip)
				else
					@@db.execute("#{@@cac_update} set ikagent_id = ?, ikagent_ip = ? , update_date = (datetime('now', 'localtime')) where ikagent_id = ? or ikagent_ip = ? ", ikagent, ip, ikagent, ip)
				end

				own_tako = ""
				own_mac  = ""
				own_app  = ""
				row = @@db.execute(@@tako_select) 
				next if row.empty? == true
				row.each do |result|
					own_tako = result[0]
					own_mac  = result[1]
				sow = @@db.execute("select tako_app from APP_List where tako_id = ?", own_tako) 	
				sow.each do |result2|
					own_app += "#{result2[0]} "
				end
				msg = " NEW-TAKO #{@@nick} #{@@ip} #{own_tako} #{own_mac} #{own_app}"
					@@irc.notice "#{ikagent}", "#{msg}"
				end
				@@db.commit 
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
				@@db.transaction
				@@db.execute("#{@@cac_delete} where ikagent_id = ? or ikagent_ip = ?", d_nick, d_ip)
				@@db.execute("#{@@cso_delete} where ikagent_id = ?", d_nick)
				@@db.execute("#{@@cat_delete} where ikagent_id = ?", d_nick)
				@@db.execute("#{@@com_delete} where ikagent_id = ?", d_nick)
				@@db.execute("#{@@exa_delete} where ikagent_id = ?", d_nick)
				@@db.commit 
				@@db.execute("vacuum")
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
				when 'RANDOM_APP'
					s_app = msg.split[9]
					s_app.encode!("UTF-8")
					IRC::random_app_reply(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@ip, s_nick, s_app)  
				when 'COMMON_APP'
					s_app_tmp = msg 
					i = 7
					while s_app_tmp.split[i] != nil
						s_app += "#{s_app_tmp.split[i]} "
						i += 1
					end
					s_app.encode!("UTF-8")
					IRC::common_app_reply(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@ip, s_nick, s_app)
				when 'EXACT_MATCH'
					tako_id = msg.split[7]
					i = 8
					while msg.split[i] != nil
						s_app += "#{msg.split[i]} "
						i += 1
					end
					s_app.encode!("UTF-8")
					IRC::exact_match_reply(@@irc, @@db, @@app_select, @@apn_select, @@tako_select, @@nick, @@ip, s_nick, s_app, tako_id)
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
				when 'RANDOM_APP'
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
						@@db.transaction
						row = @@db.execute("#{@@cac_select} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)
						if row.empty? == false
							@@db.execute("#{@@cac_update} set ikagent_id = ?, ikagent_ip = ? , update_date = (datetime('now', 'localtime')) where ikagent_id = ? or ikagent_ip = ? ", ikagent, ip, ikagent, ip)
							sow = @@db.execute("#{@@cat_select} where tako_id = ?", tako_id)
							if sow.empty? == false
								@@db.execute(@@cso_insert, ikagent, tako_id, tako_app)
							else
								@@db.execute(@@cat_insert, ikagent, tako_id, tako_mac)
								@@db.execute(@@cso_insert, ikagent, tako_id, tako_app)
							end
							p "update complete!"
						else
							@@db.execute(@@cac_insert, ikagent, ip)
							@@db.execute(@@cat_insert, ikagent, tako_id, tako_mac)
							@@db.execute(@@cso_insert, ikagent, tako_id, tako_app)
							p "insert complete!"
						end
						@@db.commit
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
						@@db.transaction
						row = @@db.execute("#{@@cac_select} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)
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
						@@db.commit
					end

				when 'EXACT_MATCH'				
					tako_id  = msg.split[8]
					tako_mac = msg.split[9] 
					own_tako = msg.split[10]
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
						@@db.transaction
						row = @@db.execute("#{@@cac_select} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)
						if row.empty? == false
							@@db.execute("#{@@cac_update} set ikagent_id = ?, ikagent_ip = ?, update_date = (datetime('now', 'localtime')) where ikagent_id = ? and ikagent_ip = ?", ikagent, ip, ikagent, ip)
							sow = @@db.execute("#{@@cat_select} where tako_id = ?", tako_id)
							if sow.empty? == true
								@@db.execute(@@cat_insert, ikagent, tako_id, tako_mac)
								@@db.execute(@@exa_insert, ikagent, tako_id, own_tako)
							else
								tow = @@db.execute("#{@@exa_select} where p_tako_id = ? and o_tako_id = ?", tako_id, own_tako)
								if tow.empty? == true	
									@@db.execute(@@exa_insert, ikagent, tako_id, own_tako)
								end
							end
							p "update complete!"
						else
							@@db.execute(@@cac_insert, ikagent, ip)
							@@db.execute(@@cat_insert, ikagent, tako_id, tako_mac)
							@@db.execute(@@exa_insert, ikagent, tako_id, own_tako)
							p "insert complete!"
						end
						@@db.commit
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

				@@db.transaction
				row = @@db.execute("#{@@cac_select} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)
				if row.empty? == true
					@@db.execute(@@cac_insert, ikagent, ip)
				else
					@@db.execute("#{@@cac_update} set ikagent_id = ?, ikagent_ip = ?, update_date = (datetime('now', 'localtime')) where ikagent_id = ? or ikagent_ip = ?", ikagent, ip, ikagent, ip)
				end	

				@@db.execute(@@cat_insert, ikagent, tako_id, tako_mac)
				i = 9
				count = 0
				while msg.split[i] != nil
					tako_app = msg.split[i]
					tako_app.encode!("UTF-8")
					@@db.execute(@@cso_insert, ikagent, tako_id, tako_app)
					i += 1
					count += 1
				end
				@@db.commit

				#if @@algo == "1" && @@smode == "1"
				#	IRC::random_app(@@db, @@input, @@output, @@cso_select)
				#elsif @@algo == "2" && @@smode == "1"
				#	IRC::common_app(@@db, @@cac_select, @@cat_select, @@app_select, @@cso_select, @@val_insert, @@val_update, @@val_select)
				if @@algo == "3" && @@smode == "1"
					@@db.execute(@@num_insert, tako_id, count)
				#	IRC::exact_match(@@db, @@tako_id, @@app_select, @@num_select, @@cso_select)
				end
				@@mutex.unlock
				@@timeout.wakeup
			end	
			########################################################

			if msg.split[1] == 'NOTICE' && msg.split[4] == 'UPD-TAKO'
				@@mutex.lock
				ikagent  = msg.split[5]
				ip       = msg.split[6]
				tako_id  = msg.split[7]
				tako_mac = msg.split[8]
				ikagent.encode!("UTF-8")
				ip.encode!("UTF-8")
				tako_id.encode!("UTF-8")
				tako_mac.encode!("UTF-8")

				@@db.transaction
				row = @@db.execute("#{@@cac_select} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)
				if row.empty? == false
					@@db.execute("#{@@cac_update} set ikagent_id = ?, ikagent_ip = ?, update_date = (datetime('now', 'localtime')) where ikagent_id = ? or ikagent_ip = ?", ikagent, ip, ikagent, ip)
				else
					@@db.execute(@@cac_insert, ikagent, ip)
				end	
			
				row = @@db.execute("#{@@cat_select} where tako_id = ?", tako_id)
				if row.empty? == true
					@@db.execute(@@cat_insert, ikagent, tako_id, tako_mac)
				else
					@@db.execute("#{@@cso_delete} where tako_id = ?", tako_id)
				end

				i = 9
				count = 0
				while msg.split[i] != nil
					tako_app = msg.split[i]
					tako_app.encode!("UTF-8")
					@@db.execute(@@cso_insert, ikagent, tako_id, tako_app)
					i += 1
					count += 1
				end
				if @@algo == "3" && @@smode == "1"
					@@db.execute(@@num_insert, tako_id, count)
				end
				@@db.commit
				@@db.execute("vacuum")
				@@mutex.unlock
			end	

			if msg.split[1] == 'NOTICE' && msg.split[4] == 'DEL-TAKO'
				@@mutex.lock
				ikagent = msg.split[5]
				ip      = msg.split[6]
				tako_id = msg.split[7]
				
				ikagent.encode!("UTF-8")
				ip.encode!("UTF-8")
				tako_id.encode!("UTF-8")
				@@db.transaction
				@@db.execute("#{@@cso_delete} where tako_id = ?", tako_id)
				@@db.execute("#{@@cat_delete} where tako_id = ?", tako_id)
				row = @@db.execute("#{@@cat_select} where ikagent_id = ?", ikagent)
				if row.empty? == true
					@@db.execute("#{@@cac_delete} where ikagent_id = ? or ikagent_ip = ?", ikagent, ip)
					@@db.execute("#{@@cso_delete} where ikagent_id = ?", ikagent)
					@@db.execute("#{@@cat_delete} where ikagent_id = ?", ikagent)
					@@db.execute("#{@@val_delete} where ikagent_id = ?", ikagent)
				end
				@@db.commit
				@@db.execute("vacuum")
				@@mutex.unlock
			end
			###############################################
			###############################################

			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'QUERY-KEY'
				ikagent = msg.split[5]
				query_app = ""
				i = 6
				while msg.split[i] != nil
					query_app += "#{msg.split[i]} "
					i += 1
				end
				
				i = 0
				value = 0
				query_app.encode!("UTF-8")
				@@db.transaction
				while query_app.split[i] != nil
					row = @@db.execute("select tako_app from APP_List where tako_app = ?", query_app.split[i])
					row.each do |result|
						value += 1
					end
					i += 1
				end
				@@db.commit
				
				next if value < 1
				msg = " KEY-REPLY #{@@nick} #{value}"
				@@irc.notice "#{ikagent}", "#{msg}"
			end

			if msg.split[1] == 'NOTICE' && msg.split[4] == 'KEY-REPLY'
				ikagent = msg.split[5]
				@@key_ikagent.push("#{ikagent}")
				@@key_timeout.wakeup
			end
				
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
					@@db.transaction
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
					@@db.execute(@@apn_insert, tako_id, count)
					p "#{@@sql_column}"
					p "#{@@sql_output}"


					# result output
				
					@@db.execute(@@sql_join) do |row|
						print "#{row[0]}, #{row[1]}, #{row[2]}\n"
					end
					
					@@db.commit
					@@tako_id = tako_id

					if @@layer == "1"
						@@layer = "0"
						@@sha_timeout.wakeup
						@@mutex.unlock
						next
					end

					case @@smode
					when "0"
						msg = ""
						case @@algo
						when "1"
							msg = IRC::random_app_query(@@irc, @@db, @@cac_select, @@cat_select, @@nick, @@app_select, @@tako_select, @@cso_select, @@input, @@output, tako_id, tako_mac)
						when "2"
							msg = IRC::common_app_query(@@irc, @@db, @@app_select, @@tako_select, @@nick, @@cac_select, @@com_select, @@input, @@output) 
						when "3"
							msg = IRC::exact_match_query(@@irc, @@db, @@app_select, @@nick, tako_id, @@exa_select, @@apn_select)
						end

						if msg.empty? == true
							@@mutex.unlock
							next
						end
						
						if @@layer == "none"
							for key in @@channel_stable do
								@@irc.privmsg "#{key}", "#{msg}"
							end
						elsif @@channel_key.empty? == true
							@@mutex.unlock
							next
						else
							for key in @@channel_key do
								@@irc.privmsg "#{key}", "#{msg}"
							end
						end

					when "1"
						if @@algo == "1"
							IRC::random_app(@@db, @@input, @@output, @@cso_select, tako_id)
						elsif @@algo == "2" 
							IRC::common_app(@@db, @@cac_select, @@cat_select, @@app_select, @@cso_select, @@val_insert, @@val_update, @@val_select)
						elsif @@algo == "3"
							IRC::exact_match(@@db, tako_id, @@app_select, @@num_select, @@cso_select)
						end

						msg = " NEW-TAKO #{@@nick} #{@@ip} #{tako_id} #{tako_mac} #{join_app}"
						if @@layer == "none"
							for key in @@channel_stable do 
								@@irc.notice "#{key}", "#{msg}"
							end

						elsif @@channel_key.empty? == true
							@@mutex.unlock
							next
						else
							for key in @@channel_key do
								@@irc.notice "#{key}", "#{msg}"
							end
						end
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
					@@db.transaction
					while poxpr_ex.split[i] != nil
						tako_app = poxpr_ex.split[i] # tako_app store
						@@db.execute("#{@@app_delete} where tako_id = ? and tako_app = ?", tako_id, tako_app)
						i += 1
						count += 1
					end
					@@db.execute("#{@@apn_update} set app_num = app_num - ? where tako_id = ?", count, tako_id)
					
					###############################
					p "#{@@sql_column}"
					p "#{@@sql_output}"
					# such channel NEW data send
					@@db.execute(@@sql_join) do |row|
						print "#{row[0]}, #{row[1]}, #{row[2]}\n"
						tako_app += "#{row[2]} "
					end
					
					@@db.commit
					@@db.execute("vacuum")

					if @@smode == "1"
						msg = " UPD-TAKO #{@@nick} #{@@ip} #{tako_id} #{tako_mac} #{tako_app}"
						for key in @@channel_stable do
							@@irc.notice "#{key}", "#{msg}"
						end
					end
					
				###############################################	
				when 'DEL'
					# setting
					tako_id = ""
					tako_id = poxpr_ex.split[1] # delete tako_id store
					####################################
					@@db.transaction
					@@db.execute("#{@@tako_delete} where tako_id = ?", tako_id)
					@@db.execute("#{@@app_delete}  where tako_id  = ?", tako_id)
					@@db.execute("#{@@apn_delete}  where tako_id  = ?", tako_id)

					p "#{@@sql_column}"
					p "#{@@sql_output}"
					# such channel NEW data send
					@@db.execute(@@sql_join) do |row|
						print "#{row[0]}, #{row[1]}, #{row[2]}\n"
					end
					@@db.commit
					@@db.execute("vacuum")

					if @@smode == "1"
						msg = " DEL-TAKO #{@@nick} #{@@ip} #{tako_id}"
						if @@layer == "none"
							for key in @@channel_stable do
								@@irc.notice "#{key}", "#{msg}"
							end
						elsif @@channel_key.empty? == true
							@@mutex.unlock
							next
						else
							for key in @@channel_key do
								@@irc.notice "#{key}", "#{msg}"
							end
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
					if @@channel.empty? == true
						@@irc.notice "#{key}", " DEL-IKAGENT #{@@nick} #{@@ip}" 
					else
						@@irc.notice "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick} #{@@ip}" # send DEL-CHANNEL message (hash table for value delete)
					end
					@@db.transaction
					@@db.execute(@@tako_delete) # data base delete 
					@@db.execute(@@app_delete) # data base delete 
					@@db.execute(@@cac_delete)
					@@db.execute(@@cat_delete)
					@@db.execute(@@cso_delete)
					@@db.commit
					@@db.execute("vacuum")
					@@db.close # database close
				end
				exit
			elsif /join/i =~ input
				str = input.split
				# process own channel opretor
				if @@channel_hash.include?(str[1]) == false && @@channel.empty? == true
					@@channel = str[1]

				end
				###############################
				@@irc.join "#{str[1]}" # channel join
			elsif /part/i =~ input
				str = input.split
				@@irc.part "#{str[1]}" # channel part
			#############################################

			# process only operator 
			elsif /topic/i =~ input && @@channel.empty? == false
				str = input.split
				@@irc.topic "#{@@channel}", "#{str[1]}" # channel topic changes
			elsif /mode/i =~ input 
				str = input.split	
				@@irc.mode "#{str[1]}", "#{str[2]} #{str[3]}" # channel mode changes
			########################################################

			# list process
			elsif /list/i =~ input
				str = input.split
				if str[1] == nil
					@@irc.list 
				elsif str[1] != nil
					@@irc.list "#{str[1]}" 
				end

			elsif /names/i =~ input
				str = input.split
				if str[1] == nil
					@@irc.names
				elsif str[1] != nil
					@@irc.names "#{str[1]}" 
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
				timeout(30) {
					while true
						sleep 
					end
				}
			rescue Timeout::Error
				p "Timeout!"
			end
		end
	end
	
	@@sha_timeout = Thread::fork do
		Thread::stop
		while true
			sleep
			begin
				timeout(30) {
					sleep
				}
			rescue Timeout::Error
				p "Share Timeout!"
				sow = @@db.execute("select tako_app from APP_List")
				sow.each do |result|
					if @@share_hash.include?("#{result[0]}") == true
						@@share_hash["#{result[0]}"] += 1
					else
						@@share_hash.store("#{result[0]}", 1)
					end
				end
				@@share_hash.sort {|(k1, v1), (k2, v2) | v2 <=> v1}
				i = 0
				join_app = ""
				@@share_hash.each do |key, value|
					break if i == 12
					join_app += "#{key} "
					print key + "=>" , value
					print EOF
					i += 1
				end
				msg = " QUERY-KEY #{@@nick} #{join_app}"
				@@channel_hash.each_key do |key|
					@@irc.privmsg "#{key}", "#{msg}"
				end
				@@key_timeout.wakeup
				@@share_hash.clear	
			end
		end
	end		
				
	@@key_timeout = Thread::fork do
		Thread::stop
		while true
			sleep
			begin
				timeout(30) {
					sleep 
				}
			rescue Timeout::Error
				p "QUERY-KEY : Timeout!" # debug

				# No Query key message process
				if @@key_ikagent.empty? == true
					@@layer = "1"
					next
				end
				##############################

				# random channel create
				o = [('a' .. 'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a}.flatten
				channel = "#" + (0..10).map { o[rand(o.length)]}.join
				################################################

				# if channel_key == 6 process
				p_cha = ""
				if @@channel_key.count == 6
					if @@channel.empty? == true
						p_cha = @@channel_key.sample
						@@irc.part("#{p_cha}")
						@@channel_key.delete("#{p_cha}")
						next
					end
					p_cha = @@channel
					while p_cha != @@channel
						p_cha = @@channel_key.sample
					end
					@@irc.part("#{p_cha}")
					@@channel_key.delete("#{p_cha}")
				end
				################################################

				@@channel = channel if @@channel.empty? == true

				@@irc.join "#{channel}"
				@@channel_key.push("#{channel}")
								
				@@key_ikagent.sort {|(k1, v1), (k2, v2) | v2 <=> v1}
				i = 0
				@@key_ikagent.each do |result|
					@@irc.invite "#{result}", "#{channel}"
					@@n_operator = result if i == 0
					i += 1
				end

				@@key_ikagent.clear # query key clear
				@@interval = i * 60
				#@@key_stop.wakeup
			end
		end
	end

	@@key_stop = Thread::fork do
		Thread::stop
		while true
			sleep
			begin
				timeout(@@interval) {
					sleep 
				}
			rescue Timeout::Error
				" Key Interval Timeout!"
				@@layer = "1"
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
				opt.on('-l', '--layer', 'layer')	     {|v| OPTS[:l] = v}
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
		if OPTS[:t] then @@topic = OPTS[:t] else @@topic = "" end
		if OPTS[:c] then @@channel = "#" + OPTS[:c] else @@channel = "" end
		if OPTS[:a] then @@algo = OPTS[:a] else @@algo = ALGO end
		if OPTS[:d] then @@dummy = "1" else @@dummy = "0" end
		if OPTS[:m] then @@smode = "1" else @@smode = "0" end
		if OPTS[:l] then @@layer = "1" else @@layer = "none" end
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
			@@db.execute(create_exact)
		end

		sql_command # sql_coomand summary method
		##################################

		# such paramater output
		puts @@server, @port,  @@nick
		puts @@channel if @@channel.empty? == false
		# irc socket create
		@@irc = IRCSocket.new(@@server, @port)
		# irc server connect
		@@irc.connect

		# connection process
		if @@irc.connected?
			@@irc.nick "#{@@nick}" # nickname decide
			@@irc.user "#{@@nick}", 0, "*", "I am #{@@nick}" # user name decide
			@@irc.list # channel list store
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
		@@sha_timeout.run
		@@key_timeout.run
		@@key_stop.run
		#######################
		
		# such thread join
		########################
		@@ping_pong.join
		@@writen.join
		@@pwn_poxpr.join
		@@timeout.join
		@@sha_timeout.join
		@@key_timeout.join
		@@key_stop.join
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

			@@exa_insert  = insert_exact
			@@exa_delete  = delete_exact
			@@exa_update  = update_exact
			@@exa_select  = select_exact

			@@sql_join    = join_table

			@@sql_column  = "tako_id             tako_mac           tako_app"
			@@sql_output  = "-------------------------------------------------"
		end

		####################################
	end
IRC::new
