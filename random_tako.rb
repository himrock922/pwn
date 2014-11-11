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

		# selection tako for query qpp
		db.execute("#{app_select} where tako_app = ? order by random()", s_app) do |row|
			if row == nil
				break
			else
			select_tako = row[0]
			select_app  = row[1]
				break
			end
		end
		##################################################

		# replay of selected tako information
		db.execute("#{tako_select} whete tako_id = ?", select_tako) do |row|
			select_mac = row[1]
		end

		irc.privmsg "#{s_nick}", " REPLAY RANDOM_TAKO #{nick} #{select_tako} #{select_app}"
	end
end
