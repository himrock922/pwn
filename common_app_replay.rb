=begin
module CommonAppQuery module
=end

module CommonAppReplay
	def common_app_replay(irc, db, app_select, tako_select, nick, ip, s_nick, s_app)
		# setting
		select_tako = ""
		join_tako   = ""
		select_app  = Array.new
		i = 0
		value = 0
		#######################
		while s_app.split[i] != nil
			db.execute("#{app_select} where tako_app = ?", s_app.split[i]) do |row|
				value += 1
			end
			i += 1
		end
		msg = " REPLAY COMMON_APP #{nick} #{ip} #{value}"
		irc.notice "#{s_nick}", "#{msg}"		
	end
end				
