=begin
RandomTako module
=end
module RandomTako 
	def random_tako(irc, db, app_select, tako_select, nick, s_nick, s_app, algo)
		# setting
		select_id  = ""
		select_mac = ""
		select_app = ""
		####################################

		p s_app
		# selection tako for query qpp
		db.execute(app_select) do |row|
			if row[1] == s_app
				select_id  = row[0]
				select_app = row[1]
				break
			end
		end
		##################################################

		# replay of selected tako information
		db.execute(tako_select) do |row|
			if row[0] == select_id
				select_mac = row[1]
				break
			end
		end

		irc.privmsg "#{s_nick}", " REPLAY RANDOM_TAKO #{nick} #{select_tako} #{select_app}"
	end
end
