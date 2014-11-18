=begin
RandomTako module
=end
module RandomTakoQuery
	def random_tako_query(irc, db, app_select, tako_select, nick, channel_stable)
		select_tako = ""
		select_app  = Array.new
		join_app    = ""
		msg = ""
		db.execute("#{tako_select} order by random()") do |row|
			select_tako = row[0]
			break
		end
		
		i = 0
		db.execute("#{app_select} where tako_id = ?", select_tako)  do |row|
			select_app[i] =  row[1]
			i += 1
		end

		i = 0
		while select_app[i] != nil
			join_app += "#{select_app[i]} "
			i += 1
		end
			
		# such channel send of infomation using of ikagent choose algorithm 
		msg = " QUERY RANDOM_TAKO #{nick} #{join_app}" 
		for key in channel_stable do
			irc.privmsg "#{key}", "#{msg}" 
		end
	end
end
