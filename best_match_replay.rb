=begin
module CommonAppQuery module
=end

module BestMatchReplay
	def best_match_replay(irc, db, app_select, tako_select, nick, ip, s_nick, s_app)
		#######################
		i = 0
		while s_app.split[i] != nil
			i += 1	
		end

		case i
		when 1
			db.execute("#{app_select} where tako_app = ? order by random()", s_app[0]) do |row|
				if row.empty? == true
					return
				end

				sow = db.execute("#{tako_select} where tako_id = ?", row[0])
				msg = "REPLAY BEST_MATCH #{nick} #{ip} #{sow[0]} #{sow[1]}"
				irc.notice "#{s_nick}", "#{msg}"
				break
			end
		end
		msg = " REPLAY COMMON_APP #{nick} #{ip} #{value}"
		irc.notice "#{s_nick}", "#{msg}"		
	end
end				
