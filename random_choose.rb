module RandomChoose 
	def random_choose(channel ,db, channel_hash)
			c_size = channel_hash.size
			p_channel  = channel_hash.keys
			
		count = 0
		own_app_tmp  = Array.new
		p_app_tmp = Array.new
		pcha_declist = Array.new

		db.execute("select * from Ikagent_List where ikagent_cha = ?", channel) do |row|
			own_app_tmp_tmp = row[5]
			own_app_tmp = own_app_tmp_tmp.split(/\|\|/)
		end

		while true
			@own_app = own_app_tmp.sample.split(/\|/)
			
			@p_tako = p_channel.sample
			if @p_tako == channel
				next
			end

			if pcha_declist.index("#{@p_tako}") != nil
				next
			end

			pcha_declist.push ("#{@p_tako}")
			

			db.execute("select * from Ikagent_List where ikagent_cha = ?", @p_tako) do |p_row|
				
				p_app_tmp_tmp  = p_row[5]
				p_app_tmp  = p_app_tmp_tmp.split(/\|\|/)
				@tako_info = p_row
			
			end

			while true

				@p_app = p_app_tmp.sample.split(/\|/)

				if @tako_info[3] == nil
					break
				end
			
				for own in @own_app do
					for par in @p_app do
						if own == par
							print "\r\n"
							p "*****************"
							p "party tako fixed!"
							p "*****************"
							p "****************************"
							p @tako_info
							p "****************************"
							count = 1
							break
						end
					end
				break if  count == 1
				end
			break if count == 1	
			end
		break if count == 1
		end
	end
end
