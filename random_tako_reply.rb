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
		row = db.execute("select tako_id from APP_List where tako_app = ? order by random()", s_app) 
		if row.empty? == true
			return
		end
		select_id = row[0]
		##################################################

		# replay of selected tako information
		
		row = db.execute("select tako_mac from TAKO_List where tako_id = ?", select_id)

		select_mac = row[0]

		msg = " REPLY RANDOM_TAKO #{nick} #{ip} #{select_id[0]} #{select_mac[0]} #{s_app}"
		irc.notice "#{s_nick}", "#{msg}"
	end
end
