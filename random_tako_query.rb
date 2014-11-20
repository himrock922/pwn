=begin
RandomTako module
=end
module RandomTakoQuery
	def random_tako_query(irc, db, app_select, tako_select, cac_select, cac_delete, nick, channel_stable)
		select_tako = ""
		select_app  = ""
		result      = ""
		msg = ""

		result = db.execute("#{cac_select} order by random()")
		if result.empty? != true
			p result
			return
		end

		db.execute("#{tako_select} order by random()") do |row|
			select_tako = row[0]
			break
		end
		
		db.execute("#{app_select} where tako_id = ? order by random()", select_tako)  do |row|
			select_app =  row[1]
			break
		end

		# such channel send of infomation using of ikagent choose algorithm 
			msg = " QUERY RANDOM_TAKO #{nick} #{select_app}" 
			for key in channel_stable do
				irc.privmsg "#{key}", "#{msg}" 
			end
	end
end
