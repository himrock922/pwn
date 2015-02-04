=begin
module CommonAppQuery module
=end

module ExactMatch
	def exact_match(db, tako_id, app_select, num_select, cso_select)
		#######################
		i = 0
		s_app = Array.new
		select_tako = Array.new
		row = db.execute("select tako_app from APP_List where tako_id = ?", tako_id) 	
		
		row.each do |result|
			s_app.push("#{result[0]}")
			i += 1
		end

		case i
		when 1
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 1) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[0])
					next if sow.empty? == true
					select_tako.push ("#{result[0]}")
				end
			end
			db.commit
		when 2
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 2) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 2 
						sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 1
						i += 1
					end
				end
			end
			db.commit
		when 3 
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 3) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i <3 
						sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 2
						i += 1
					end
				end
			end
			db.commit
		when 4 
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 4) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 4
						sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 3
						i += 1
					end
				end
			end
			db.commit
		when 5 
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 5) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 5
						sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 4
						i += 1
					end
				end
			end
			db.commit
		when 6 
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 6) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 6
						sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 5
						i += 1
					end
				end
			end
			db.commit
		when 7 
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 7) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 7
						sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 6
						i += 1
					end
				end
			end
			db.commit
		when 8 
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 8) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 8
						sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 7
						i += 1
					end
				end
			end
			db.commit
		when 9 
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 9) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 9
						sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 8
						i += 1
					end
				end
			end
			db.commit
		when 10 
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 10) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 10
						sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 9
						i += 1
					end
				end
			end
			db.commit
		when 11 
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 11) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 11
						sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 10
						i += 1
					end
				end
			end
			db.commit
		when 12
			db.transaction 
			row = db.execute("select distinct tako_id from Number where app_num = ? order by random()", 12) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 12
						sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 11
						i += 1
					end
				end
			end
			db.commit
		end
		return if select_tako.empty? == true
		db.transaction
		print "\r\n"
		p "*************************"
		p "****party tako fixed!****"
		p "*************************"
		select_tako.each do |result|
			row = db.get_first_row("select ikagent_id from CacheSelectOne where tako_id = ?", result)
			sow = db.get_first_row("select tako_mac from CacheTako where tako_id = ?", result)
			tow = db.get_first_row("select ikagent_ip from Cache where ikagent_id = ?", row[0])
			print "#{row[0]} #{tow[0]} #{result} #{sow[0]}\n"
		end
		db.commit
	end
end				
