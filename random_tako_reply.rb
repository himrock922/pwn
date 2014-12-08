=begin
RandomTako module
=end
module RandomTakoReply 
	def random_tako_reply(irc, db, app_select, tako_select, nick, ip, s_nick, s_app)
		# setting
		select_id  = ""
		select_mac = ""
		msg        = ""
		####################################

		# selection tako for query qpp
		db.execute("#{app_select} where tako_app = ? order by random()", s_app) do |row|
			select_id = row[0]
			break
		end
		if select_id.empty? == true
			return
		end
		##################################################

		# replay of selected tako information
		
		db.execute("#{tako_select} where tako_id = ?", select_id) do |row|
			select_mac = row[1]
			break
		end

		msg = " REPLY RANDOM_TAKO #{nick} #{ip} #{select_id} #{select_mac} #{s_app}"
		irc.notice "#{s_nick}", "#{msg}"
	end
end
