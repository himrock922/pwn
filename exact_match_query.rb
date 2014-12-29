=begin
RandomTako module
=end
module ExactMatchQuery
	def exact_match_query(irc, db, app_select, nick, tako_id, cso_select, apn_select)
		join_app   = ""
		msg        = ""
		s_app = Array.new
		i = 0
		@@select_tako   = ""
		db.execute("#{app_select} where tako_id = ?", tako_id) do |row|
			join_app += "#{row[1]} "
			s_app[i] = row[1]
			i += 1
		end

		db.execute("#{cso_select} where tako_app = ?", tako_id) do |row|
			
			if row.empty? == true
				case i
				when 1
					db.execute("#{apn_select} where app_num = ? order by random()", 1) do |row|
					if row.empty? == true
						break
					else
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
						if sow.empty? == true
							next
						else
							@@select_tako = row[0]
							break
						end	
					end
				end
		
				when 2
					db.execute("#{apn_select} where app_num = ? order by random()", 2) do |row|
					if row.empty? == true
						break
					else
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
						next if sow.empty? == true
						tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					if tow.empty? == true
						next
					else
						@@select_tako = row[0]
						break
					end
				end
			end

		when 3 
			db.execute("#{apn_select} where app_num = ? order by random()", 3) do |row|
				if row.empty? == true
					break
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					if uow.empty? == true
						next
					else
						@@select_tako = row[0]
						break
					end
				end
			end
		when 4 
			db.execute("#{apn_select} where app_num = ? order by random()", 4) do |ron|
				if row.empty? == true
					break	
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					
					if vow.empty? == true
						next
					else
						@@select_tako = row[0]
						break
					end
				end
			end
		when 5 
			db.execute("#{apn_select} where app_num = ? order by random()", 5) do |row|
				if row.empty? == true
					break	
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					if wow.empty? == true
						next
					else
						@@select_tako = row[0]
						break
					end
				end
			end
		when 6 
			db.execute("#{apn_select} where app_num = ? order by random()", 6) do |row|
				if row.empty? == true
					break
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					if xow.empty? == true
						next
					else
						@@select_tako = row[0]
						break
					end
				end
			end
		when 7 
			db.execute("#{apn_select} where app_num = ? order by random()", 7) do |row|
				if row.empty? == true
					break
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					if yow.empty? == true
						next
					else
						@@select_tako = row[0]
						break
					end
				end
			end
		when 8 
			db.execute("#{apn_select} where app_num = ? order by random()", 8) do |row|
				if row.empty? == true
					break	
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					next if yow.empty? == true
					zow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[7])
					if zow.empty? == true
						next
					else
						@@select_tako = row[0]
						break
					end
				end
			end
		when 9 
			db.execute("#{apn_select} where app_num = ? order by random()", 9) do |row|
				if row.empty? == true
					break	
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					next if yow.empty? == true
					zow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[7])
					next if zow.empty? == true
					aow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[8])
					if aow.empty? == true
						next
					else
						@@select_tako = row[0]
						break
					end
				end
			end
		when 10 
			db.execute("#{apn_select} where app_num = ? order by random()", 10) do |row|
				if row.empty? == true
					break
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					next if yow.empty? == true
					zow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[7])
					next if zow.empty? == true
					aow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[8])
					next if aow.empty? == true
					bow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[9])
					if bow.empty? == true
						next
					else
						@@select_tako = row[0]
						break
					end
				end
			end
		when 11 
			db.execute("#{apn_select} where app_num = ? order by random()", 11) do |row|
				if row.empty? == true
					break	
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					next if yow.empty? == true
					zow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[7])
					next if zow.empty? == true
					aow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[8])
					next if aow.empty? == true
					bow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[9])
					next if bow.empty? == true
					cow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[10])
					if cow.empty? == true
						next
					else
						@@select_tako = row[0]
						break
					end
				end
			end
		when 12 
			db.execute("#{apn_select} where app_num = ? order by random()", 12) do |row|
				if row.empty? == true
					break
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					next if yow.empty? == true
					zow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[7])
					next if zow.empty? == true
					aow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[8])
					next if aow.empty? == true
					bow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[9])
					next if bow.empty? == true
					cow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[10])
					next if cow.empty? == true
					dow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[11])
					if dow.empty? == true
						next
					else
						@@select_tako = row[0]
						break
					end
				end
			end
		end
	
		else
			@@select_tako = row[0]
		end

		 if @@select_tako.empty? == false			
			db.execute("select * from CacheTako left outer join CacheSelectOne on CacheTako.tako_id = CacheSelectOne.tako_id where CacheSelectOne.tako_id = ?", @@select_tako) do |sow|
				db.execute("select * from Cache left outer join CacheTako on Cache.ikagent_ip = CacheTako.ikagent_ip where CacheTako.ikagent_id = ?", sow[0]) do |tow|
					line = output.gets.chomp
					if line == "\"Timeout!\""
						print "\r\n"
						p "****************************"
						p "***** party tako fixed! ****"
						p "****************************"
						input.puts "#{tow[0]}, #{tow[1]}, #{sow[1]}, #{sow[2]}"
						print "#{tow[0]}, #{tow[1]}, #{sow[1]}, #{sow[2]}\n"
						db.execute("delete from CacheSelectOne where tako_id = ?", row[0])
						db.execute("delete from CacheTako where ikagent_id = ?", sow[0])
						return
					else
						return
					end
				end
			end
		end
	end

		# such channel send of infomation using of ikagent choose algorithm 
			msg = " QUERY BEST_MATCH #{nick} #{join_app}" 
			return msg
	end
end
