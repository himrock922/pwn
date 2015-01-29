=begin
RandomTako module
=end
module RandomAppReply 
	def random_app_reply(irc, db, app_select, tako_select, nick, ip, s_nick, s_app)
		# setting
		select_id  = ""
		select_mac = ""
		msg        = ""
		####################################

		# selection tako for query qpp
		db.transaction
		row = db.get_first_row("select tako_id from APP_List where tako_app = ? order by random()", s_app) 
		select_id = row
		if select_id.empty? == true
			db.commit
			return
		end
		##################################################

		# replay of selected tako information
		
		row = db.get_first_row("select tako_mac from TAKO_List where tako_id = ?", select_id)

		select_mac = row

		db.commit 

		msg = " REPLY RANDOM_APP #{nick} #{ip} #{select_id} #{select_mac} #{s_app}"
		irc.notice "#{s_nick}", "#{msg}"
	end
end
