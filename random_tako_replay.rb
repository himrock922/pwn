=begin
RandomTako module
=end
module RandomTakoReplay 
	def random_tako_replay(irc, db, app_select, tako_select, nick, ip, s_nick, s_app)
		# setting
		select_id  = ""
		select_mac = ""
		join_app   = ""
		msg        = ""
		####################################

		# selection tako for query qpp
		db.execute("#{app_select} where tako_app = ? order by random()", s_app) do |row|
		if row.empty? == true
			return
		end
		select_id = row[0]
		end
		##################################################
		db.execute("#{app_select} where tako_id = ?", select_id) do |row|
			join_app += "#{row[1]} "
		end

		# replay of selected tako information
		db.execute("#{tako_select} where tako_id = ?", select_id) do |row|
			select_mac = row[1]
		end

		msg = " REPLAY RANDOM_TAKO #{nick} #{ip} #{select_id} #{select_mac} #{join_app}"
		irc.privmsg "#{s_nick}", "#{msg}"
	end
end
