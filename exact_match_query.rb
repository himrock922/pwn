=begin
RandomTako module
=end
module ExactMatchQuery
	def exact_match_query(irc, db, app_select, nick, tako_id, exa_select, apn_select)
		join_app   = ""
		msg        = ""
		s_app = Array.new
		i = 0
		select_tako   = ""

		row = db.execute("#{app_select} where tako_id = ?", tako_id)
		row.each do |result|
			join_app += "#{result[1]} "
			s_app.push("#{result[1]}")
			i += 1
		end
		row = db.execute("#{exa_select} where p_tako_id = ?", tako_id) 		
		
		if row.nill? == false
			row.each do |result|
				sow = db.get_first_row("select tako_mac from CacheTako where tako_id = ?", result[1])
				tow = db.get_first_row("select ikagent_ip from Cache where ikagent_id = ?", result[0])	
				line = output.gets.chomp
				print "\r\n"
				p "****************************"
				p "***** party tako fixed! ****"
				p "****************************"
				if line == "\"Timeout!\""
					input.puts "#{result[0]}, #{tow[0]}, #{result[1]} #{sow[0]}"
					print "#{result[0]}, #{tow[0]}, #{result[1]} #{sow[0]}\n"
					db.execute("delete from CacheSelectOne where tako_id = ?", result[1])
					db.execute("delete from CacheTako where ikagent_id = ?", result[0])

					uow = db.execute("select * from CacheTako where ikagent_id = ?", result[0])
					if uow.empty? == true
						db.execute("delete from Cache where ikagent_id = ?", result[0])
					end
					return
				else
					print "#{result[0]}, #{tow[0]}, #{result[1]} #{sow[0]}\n"
					return
				end
			end
		end

		# such channel send of infomation using of ikagent choose algorithm 
		msg = " QUERY EXACT_MATCH #{nick} #{tako_id} #{join_app}" 
		return msg
	end
end
