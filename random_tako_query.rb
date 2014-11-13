=begin
RandomTako module
=end
module RandomTakoQuery
	def random_tako_query(irc, db, app_select, tako_select, nick, channel_stable)
		select_tako = ""
		select_app  = ""
		db.execute("#{tako_select} order by random()") do |row|
			select_tako = row[0]
			break
		end

		db.execute("#{app_select} where tako_id = ? order by random()", select_tako)  do |row|
			select_app =  row[1]
			break
		end
		# such channel send of infomation using of ikagent choose algorithm 
		for key in channel_stable do
			msg = " QUERY RANDOM_TAKO #{nick} #{select_app}" 
			irc.privmsg "#{key}", "#{msg}" 
		end
	end
end
