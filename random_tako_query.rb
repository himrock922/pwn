=begin
RandomTako module
=end
module RandomTakoQuery
	def random_tako_query(irc, db, app_select, tako_select, cac_select, nick, channel_stable)
		select_tako = ""
		select_app  = ""
		result      = ""
		msg = ""
		result = db.execute("#{cac_select} order by random()")
		if result.empty != true
			p result
			db.execute("#{cac_delete} where ikagent_nick =?", result[0])
		db.execute("#{tako_select} order by random()") do |row|
			select_tako = row[0]
			break
		end
		
		i = 0
		db.execute("#{app_select} where tako_id = ?", select_tako)  do |row|
			select_app =  row[1]
		end

		result = db.execute("#{cac_select} where tako_app = ?", select_app)
		if result.empty != true
			p result
			db.execute("#{cac_delete} where ikagent_nick = ?", result[0])
			return
		else
			# such channel send of infomation using of ikagent choose algorithm 
			msg = " QUERY RANDOM_TAKO #{nick} #{select_app}" 
			for key in channel_stable do
				irc.privmsg "#{key}", "#{msg}" 
			end
		end
	end
end
