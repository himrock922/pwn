=begin
RandomTako module
=end
module ExactMatchQuery
	def exact_match_query(irc, db, app_select, nick, tako_id, exa_select, apn_select)
		join_app   = ""
		msg        = ""
		s_app = Array.new
		i = 0
		@@select_tako   = ""
		row = db.execute("#{app_select} where tako_id = ?", tako_id)
		row.each do |result|
			join_app += "#{result[1]} "
			s_app.push("#{result[1]}")
			i += 1
		end

		row = db.execute("#{exa_select} where p_tako_id = ?", tako_id) 		
		if row.empty? == false
			row.each do |result|
				sow = db.get_first_row("select tako_mac from CacheTako where tako_id = ?", result[1])
				tow = db.get_first_row("select ikagent_ip from Cache where ikagent_id = ?", result[0])	
				line = output.gets.chomp
				print "\r\n"
				p "****************************"
				p "***** party tako fixed! ****"
				p "****************************"
				if line == "\"Timeout!\""
					input.puts "#{result[0]}, #{tow[0]}, #{result[1]} #{sow[0]}"
					print "#{result[0]}, #{tow[0]}, #{result[1]} #{sow[0]}\n"
					db.execute("delete from CacheSelectOne where tako_id = ?", result[1])
					db.execute("delete from CacheTako where ikagent_id = ?", result[0])

					uow = db.execute("select * from CacheTako where ikagent_id = ?", result[0])
					if uow.empty? == true
						db.execute("delete from Cache where ikagent_id = ?", result[0])
					end

					return
				else
					print "#{result[0]}, #{tow[0]}, #{result[1]} #{sow[0]}\n"
					return
				end
			end
		else
			case i
			when 1
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 1) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[0])
					next if sow.empty? == true
					select_tako.push ("#{result[0]}")
				end
			end
			db.commit
		when 2
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 2) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 2 
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 1
						i += 1
					end
				end
			end
			db.commit
		when 3 
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 3) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i <3 
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 2
						i += 1
					end
				end
			end
			db.commit
		when 4 
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 4) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 4
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 3
						i += 1
					end
				end
			end
			db.commit
		when 5 
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 5) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 5
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 4
						i += 1
					end
				end
			end
			db.commit
		when 6 
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 6) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 6
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 5
						i += 1
					end
				end
			end
			db.commit
		when 7 
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 7) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 7
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 6
						i += 1
					end
				end
			end
			db.commit
		when 8 
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 8) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 8
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 7
						i += 1
					end
				end
			end
			db.commit
		when 9 
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 9) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 9
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 8
						i += 1
					end
				end
			end
			db.commit
		when 10 
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 10) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 10
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 9
						i += 1
					end
				end
			end
			db.commit
		when 11 
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 11) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 11
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 10
						i += 1
					end
				end
			end
			db.commit
		when 12
			db.transaction 
			row = db.execute("select distinct tako_id from AppNum where app_num = ? order by random()", 12) 	
			if row.empty? == true
				db.commit
				return
			else

				row.each do |result|
					i = 0
					while i < 12
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app[i])
						break if sow.empty? == true
						select_tako.push ("#{result[0]}") if i == 11
						i += 1
					end
				end
			end
			db.commit
		end
		end

		# such channel send of infomation using of ikagent choose algorithm 
		msg = " QUERY EXACT_MATCH #{nick} #{tako_id} #{join_app}" 
		return msg
	end
end
