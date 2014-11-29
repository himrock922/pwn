=begin
RandomTako module
=end
module BestMatchQuery
	def best_match_query(irc, db, channel_stable, app_select, nick, tako_id)
		join_app   = ""
		msg        = ""

		db.execute("#{app_select} where tako_id = ?", tako_id) do |row|
			join_app += "#{row[1]} "
		end

		# such channel send of infomation using of ikagent choose algorithm 
			msg = " QUERY BEST_MATCH #{nick} #{join_app}" 
			for key in channel_stable do
				irc.privmsg "#{key}", "#{msg}" 
			end
	end
end
