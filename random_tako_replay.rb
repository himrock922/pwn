=begin
RandomTako module
=end
module RandomTakoReplay 
	def random_tako_replay(irc, db, app_select, tako_select, nick, ip, s_nick, s_app)
		# setting
		select_id  = ""
		select_app = Array.new
		join_app   = ""
		msg        = ""
		####################################

		# selection tako for query qpp
		db.execute("#{app_select} where tako_app = ? order by random()", s_app) do |row|
			select_id = row[0]
		end
		if select_id.empty? == true
			return
		end
		##################################################

		# replay of selected tako information
		i = 0
		db.execute("#{app_select} where tako_id = ?", select_id) do |row|
			select_app[i] = row[1]
			i += 1
		end
		i = 0
		while select_app[i] != nil
			join_app += "#{select_app[i]} "
			i += 1
		end
		msg = "REPLAY RANDOM_TAKO #{nick} #{ip} #{select_id} #{join_app}"
		irc.privmsg "#{s_nick}", "#{msg}"
	end
end
