module RandomChoose 
	def test(channel ,db, channel_hash)
			c_size = channel_hash.size
			p_channel  = channel_hash.keys
			
		db.execute("select * from Ikagent_List where ikagent_cha = ?", channel) do |row|
			@own_app = Array.new
			own_app_tmp = row[5].split(/\|\|/)
			@own_app = own_app_tmp[0].split(/\|/)
		end
		count = 0
		while true
			@p_tako = p_channel.sample
			if @p_tako == channel
				next
			end
			db.execute("select * from Ikagent_List where ikagent_cha = ?", @p_tako) do |p_row|
				if p_row[3] == nil
					next
				end
				
				p_app_tmp  = p_row[5].split(/\|\|/)
				@p_app     = p_app_tmp[0].split(/\|/)
				@tako_info = p_row
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
	end
end
