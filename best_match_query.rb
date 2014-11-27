=begin
RandomTako module
=end
module BestMatchQuery
	def best_match_query(irc, db, app_select, nick, ip, tako_id)
		
		select_app = Array.new
		join_app   = ""
		msg        = ""
		i = 0

		db.execute("#{app_select} where tako_id = ?", tako_id) do |row|
			select_app[i] = row[1]
			i += 1
		end

		i = 0
		while select_app [i] != nil
			join_app += "#{select_app[i] }"
			i += 1
		end

		# such channel send of infomation using of ikagent choose algorithm 
			msg = " QUERY BEST_MATCH #{nick} #{ip} #{join_app}" 
			for key in channel_stable do
				irc.privmsg "#{key}", "#{msg}" 
			end
	end
end
