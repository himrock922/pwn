=begin
RandomTako module
=end
module RandomAppQuery
	def random_app_query(irc, db, cac_select, cat_select, nick, app_select, tako_select, cso_select, input, output, tako_id)
		result      = ""
		msg         = ""
		select_tako = ""
		select_app  = ""

		db.transaction
		row = db.get_first_row("select tako_app from APP_List where tako_id = ? order by random()", tako_id)
		select_app = row

		row = db.execute("#{cso_select} where tako_app = ? order by random()", select_app[0])
		if row.empty? == false
			row.each do |result|
			sow = db.get_first_row("select tako_mac from CacheTako where tako_id = ?", result[1])
			tow = db.get_first_row("select ikagent_ip from Cache where ikagent_id = ?", result[0])
			line = output.gets.chomp
				print "\r\n"
				p "*************************"
				p "****party tako fixed!****"
				p "*************************"
				if line == "\"Timeout!\""
					input.puts "#{result[0]}, #{tow[0]}, #{result[1]} #{sow[0]}"
					print "#{result[0]}, #{tow[0]}, #{result[1]} #{sow[0]}\n"
					db.execute("delete from CacheSelectOne where tako_id = ?", result[1])
					db.execute("delete from CacheTako where tako_id = ?", result[1])
					uow = db.execute("select from CacheSelectOne where ikagent_id = ?", result[0])
					if uow.empty? == true
						db.execute("delete from Cache where ikagent_id = ?", result[0])
					end
				else
					print "#{result[0]}, #{tow[0]}, #{result[1]} #{sow[0]}\n"
				end
			end
			return
		end
		# such channel send of infomation using of ikagent choose algorithm 
		db.commit
		db.execute("vacuum")

		msg = " QUERY RANDOM_APP #{nick} #{select_app[0]}" 
		return msg
	end
end
