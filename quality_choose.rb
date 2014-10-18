module QualityChoose
	def quality_choose(channel ,db, channel_hash)
			c_size = channel_hash.size
			p_channel  = channel_hash.keys
			
		own_app_tmp  = Array.new
		p_app_tmp = Array.new
		pcha_declist = Array.new
		evalue = 0
		@tako_info = Array.new
		db.execute("select * from Ikagent_List where ikagent_cha = ?", channel) do |row|
			own_app_tmp_tmp = row[5]
			own_app_tmp = own_app_tmp_tmp.split(/\|\|/)
		end

		i = 0
		@own_app = Array.new
		while own_app_tmp[i] != nil
			own_app_store = own_app_tmp[i].split(/\|/)
			own_app_store.each do |tmp|
				@own_app.push(tmp)
			end
			i += 1
		end
			@own_app_com = @own_app.uniq
			p_channel.each do | p_tako |
				if p_tako == channel
					next
				end

			db.execute("select * from Ikagent_List where ikagent_cha = ?", p_tako) do |p_row|

				p_app_tmp_tmp  = p_row[5]
				p_app_tmp  = p_app_tmp_tmp.split(/\|\|/)

			if p_app_tmp == nil
				next
			end

			j = 0

			@p_app = Array.new
			while p_app_tmp[j] != nil
				p_app_store = p_app_tmp[j].split(/\|/)
				p_app_store.each do |tmp|
					@p_app.push(tmp)
				end
				j += 1
			end
			@p_app_com = @p_app.uniq

			evalue_tmp = 0
				for own in @own_app_com do
					for par in @p_app_com do
						if own == par
							evalue_tmp += 1
						end
					end
				end
				if evalue_tmp > evalue
					evalue = evalue_tmp
					@tako_info = p_row
				end
			end
		end
		print "\r\n"
		p "*****************"
		p "party tako fixed!"
		p "*****************"
		p "****************************"
		p @tako_info
		p "****************************"				
	end	
end
