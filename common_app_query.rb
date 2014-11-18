=begin
module CommonAppQuery module
=end

module CommonAppQuery
	def common_app_query(irc, db, app_select, tako_select, nick, channel_stable)
		select_tako = ""
		select_app  = Array.new
		join_app    = ""
		msg         = ""
		i = 0
		db.execute(tako_select) do |row|
			select_tako = row[0]
			db.execute("#{app_select} where tako_id = ?", select_tako) do |row2|
				select_app[i] = row2[1]
				i += 1
			end
		end

		i = 0
		while select_app[i] != nil
			join_app += "#{select_app[i]} "
			i += 1
		end
		
		msg = " QUERY COMMON_APP #{nick} #{join_app}"

		for key in channel_stable do
			irc.privmsg "#{key}", "#{msg}"
		end		
	end
end				
