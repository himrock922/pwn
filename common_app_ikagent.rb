=begin
module CommonAppIkagent module
=end

module CommonAppIkagent
	def common_app_ikagent(nick ,db, hash)
		# setting
		h_size  = hash.size
		p_nick  = hash.keys	
		own_app_tmp  = Array.new
		p_app_tmp = Array.new
		pcha_declist = Array.new
		evalue = 0
		@tako_info = Array.new
		##############################
		db.execute("select * from Ikagent_List") do |row|
			p row
		end

		# own information store
		db.execute("select * from Ikagent_List where ikagent_nick = ?", nick) do |row|
			own_app_tmp_tmp = row[4]
			own_app_tmp = own_app_tmp_tmp.split(/\|\|/)
		end
		####################################################

		i = 0
		@own_app = Array.new
		
		# all app information store
		while own_app_tmp[i] != nil
			own_app_store = own_app_tmp[i].split(/\|/)
			own_app_store.each do |tmp|
				@own_app.push(tmp)
			end
			i += 1
		end
		####################################

		@own_app_com = @own_app.uniq # delete duplicate
		# other channel store
		p_nick.each do |p_tako|
			next if p_tako == nick # if own_channel store next
		# party tako decide process
		db.execute("select * from Ikagent_List where ikagent_nick = ?", p_tako) do |p_row|
			p_app_tmp_tmp  = p_row[4]
			p_app_tmp  = p_app_tmp_tmp.split(/\|\|/)

			next if p_app_tmp == nil # if nil next

			j = 0			
			@p_app = Array.new

			# party ikagent app settle
			while p_app_tmp[j] != nil
				p_app_store = p_app_tmp[j].split(/\|/)
				p_app_store.each do |tmp|
					@p_app.push(tmp)
				end
				j += 1
			end
			##########################
			@p_app_com = @p_app.uniq # duplicate delete

			evalue_tmp = 0 # eval paramater tmp setting

				# own_app and party_app scanning
				for own in @own_app_com do
					for par in @p_app_com do
						evalue_tmp += 1 if own == par # if matching evalue_tmp increase
					end
				end
				db.execute("update Ikagent_List set ikalue = ? where ikagent_nick = ?", evalue_tmp, p_tako)
				#if evalue_tmp > evalue
				#	evalue = evalue_tmp
				#	@tako_info = p_row # tako information store
				#end
				###########################
			end
		end
		# result output
		print "\r\n"
		p "*****************"
		p "party tako fixed!"
		p "*****************"
		p "****************************"
		db.execute("select * from Ikagent_List order by ikalue desc") do |row|
			p row
		end
		p "****************************"
		#################################				
	end	
end
