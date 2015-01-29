=begin
module CommonAppQuery module
=end

module CommonAppReply
	def common_app_reply(irc, db, app_select, tako_select, nick, ip, s_nick, s_app)
		# setting
		select_tako = ""
		join_tako   = ""
		select_app  = Array.new
		i = 0
		value = 0
		#######################
		db.transaction
		while s_app.split[i] != nil
			row = db.execute("#{app_select} where tako_app = ?", s_app.split[i])
			row.each do |result|
				value += 1
			end
			i += 1
		end
		db.commit
		msg = " REPLY COMMON_APP #{nick} #{ip} #{value}"
		irc.notice "#{s_nick}", "#{msg}"		
	end
end				
