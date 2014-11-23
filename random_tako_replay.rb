=begin
RandomTako module
=end
module RandomTakoReplay 
	def random_tako_replay(irc, db, app_select, tako_select, nick, ip, s_nick, s_app)
		# setting
		select_id  = ""
		select_mac = ""
		msg        = ""
		####################################

		# selection tako for query qpp
		row = db.execute("#{app_select} where tako_app = ? order by random()", s_app)
		if row.empty? == true
			return
		end
		select_id = row[0]
		##################################################

		# replay of selected tako information
		
		row = db.execute("#{tako_select} where tako_id = ?", select_id)
		select_mac = row[1]

		msg = " REPLAY RANDOM_TAKO #{nick} #{ip} #{select_id} #{select_mac} #{s_app}"
		irc.notice "#{s_nick}", "#{msg}"
	end
end
