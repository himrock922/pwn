=begin
RandomTako module
=end
module RandomTakoQuery
	def random_tako_query(irc, db, cac_select, cat_select, nick, ip, channel_stable, app_select, tako_select, cso_select, input, output)
		result      = ""
		msg         = ""
		select_tako = ""
		select_app  = ""

		row = db.execute("select tako_id from TAKO_List order by random()") 
		select_tako = row[0]

		row = db.execute("select tako_app from APP_List where tako_id = ? order by random()", select_tako[0])
		select_app = row[0]

		row = db.execute("#{cso_select} where tako_app = ? order by random()", select_app[0])
		
		if row.empty? == false
			sow = db.execute("select * from CacheTako left outer join CacheSelectOne on CacheTako.tako_id = CacheSelectOne.tako_id where CacheSelectOne.tako_id = ?", row[0])
			tow = db.execute("select * from Cache left outer join CacheTako on Cache.ikagent_ip = CacheTako.ikagent_ip where CacheTako.ikagent_ip = ?", sow[0]) 
			line = output.gets.chomp
			if line == "\"Timeout!\""
				print "\r\n"
				p "*************************"
				p "****party tako fixed!****"
				p "*************************"
				input.puts "#{tow[0]}, #{tow[1]}, #{sow[1]} #{sow[2]} #{row[1]}"
				input.close
				print "#{tow[0]}, #{tow[1]}, #{sow[1]} #{sow[2]} #{row[1]}\n"
				db.execute("delete from CacheSelectOne where tako_id = ?", row[0])
				db.execute("delete from CacheTako where ikagent_ip = ?", sow[0])
				db.execute("delete from Cache where ikagent_ip = ?", sow[0])
				return
			else
				return
			end
		end

		# such channel send of infomation using of ikagent choose algorithm 
			msg = " QUERY RANDOM_TAKO #{nick} #{ip} #{select_app[0]}" 
			for key in channel_stable do
				irc.privmsg "#{key}", "#{msg}" 
			end
	end
end
