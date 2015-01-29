=begin
module CommonAppQuery module
=end

module ExactMatchReply
	def exact_match_reply(irc, db, app_select, apn_select, tako_select, nick, ip, s_nick, s_app, tako_id)
		#######################
		i = 0
		select_tako = Array.new
		select_mac  = ""

		while s_app.split[i] != nil
			i += 1	
		end

		case i
		when 1
			db.transaction
			row = db.execute("select ditinct tako_id from AppNum where app_num = ? order by random()", 1) 
			if row.empty? == true
				db.commit
				return
			else
				row.each do |result|
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[0])
					next if  sow.empty? == true
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
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[i])
						break if sow.empty? == true
						select_tako.push("#{result[0]}") if i == 1
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
					while i < 3
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[i])
						break if sow.empty? == true
						select_tako.push("#{result[0]}") if i == 2
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
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[i])
						break if sow.empty? == true
						select_tako.push("#{result[0]}") if i == 3
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
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[i])
						break if sow.empty? == true
						select_tako.push("#{result[0]}") if i == 4
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
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[i])
						break if sow.empty? == true
						select_tako.push("#{result[0]}") if i == 5
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
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[i])
						break if sow.empty? == true
						select_tako.push("#{result[0]}") if i == 6
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
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[i])
						break if sow.empty? == true
						select_tako.push("#{result[0]}") if i == 7
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
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[i])
						break if sow.empty? == true
						select_tako.push("#{result[0]}") if i == 8
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
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[i])
						break if sow.empty? == true
						select_tako.push("#{result[0]}") if i == 9
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
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[i])
						break if sow.empty? == true
						select_tako.push("#{result[0]}") if i == 10
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
						sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", result[0], s_app.split[i])
						break if sow.empty? == true
						select_tako.push("#{result[0]}") if i == 11
						i += 1
					end
				end
			end
			db.commit
		end

		return if select_tako.empty? == true
		db.transaction
		select_tako.each do |result|
			row = db.get_first_row("select tako_mac from CacheTako where tako_id = ?", result)

			msg = " REPLY EXACT_MATCH #{nick} #{ip} #{result} #{row[0]} #{tako_id}"
			irc.notice "#{s_nick}", "#{msg}"
		end
		db.commit 
	end
end				
