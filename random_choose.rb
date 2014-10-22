=begin
RandomChoose Module
=end
module RandomChoose 
	def random_choose(nick ,db, channel_hash)
		# setting
		c_size = channel_hash.size # channel hash table size acquisitoon
		p_channel  = channel_hash.keys	# only keys acquisition
		count = 0 
		own_app_tmp  = Array.new
		p_app_tmp = Array.new
		pcha_declist = Array.new
		####################################

		# own channel information acquisition
		db.execute("select * from Ikagent_List where ikagent_nick = ?", nick) do |row|
			own_app_tmp_tmp = row[5]
			own_app_tmp = own_app_tmp_tmp.split(/\|\|/)
		end
		##################################################

		# random loop
		while true
			@own_app = own_app_tmp.sample.split(/\|/)
			break if @own_app == nil
			while true			
				@p_tako = p_channel.sample # party tako choose for random
				next if @p_tako == nick # if @p_tako = own_channel next
				next if pcha_declist.index("#{@p_tako}") != nil # if get the channel scan has finished already, exit
				if pcha_declist == p_channel
					count = 1
					break
				end
				pcha_declist.push ("#{@p_tako}") # scan channel store

				####################################

				# channel inforamtion store of acquired at random
				db.execute("select * from Ikagent_List where ikagent_nick = ?", @p_tako) do |p_row|	
					p_app_tmp_tmp  = p_row[5]
					p_app_tmp  = p_app_tmp_tmp.split(/\|\|/)
					@tako_info = p_row
				end
				next if @tako_info[3] == nil # if party_tako_app = nil break
				################################################
				papp_declist = Array.new
				# the scanning of the own_tako and party_tako
				while true
					p_com_tmp = p_app_tmp.sample
					@p_app = p_com_tmp.split(/\|/)
					
					next if papp_declist.index("#{p_com_tmp}") != nil # if get the channel scan has finished already, exit
					break if papp_declist == p_app_tmp
	
					papp_declist.push ("#{p_com_tmp}") # scan channel store
	
					for own in @own_app do
						for par in @p_app do
							# if a match if found, the resulting output information of the other
							if own == par
								print "\r\n"
								p "*****************"
								p "party tako fixed!"
								p "*****************"
								p "****************************"
								p @tako_info
								p "****************************"
								count = 1 # loop break
								break
							end
							##############################3
						end
					break if  count == 1 # loop break
					end
					################################
				break if count == 1	# loop break
				end
				######################################
			break if count == 1 # loop break
			end
			###############################
		break if count == 1 # loop break
		end
	end
end
