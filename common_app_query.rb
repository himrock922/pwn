=begin
module CommonAppQuery module
=end

module CommonAppQuery
	def common_app_query(irc, db, app_select, tako_select, nick, cac_select, com_select, input, output)
		select_tako = ""
		select_app  = Array.new
		join_app    = ""
		msg         = ""

		db.transaction
		row = db.execute("#{com_select} order by app_num asc") 
		if row.empty? == false
			row.each do |result|
				sow = db.get_first_row("select ikagent_ip from Cache where ikagent_id =?", result[0])		
				line = output.gets.chomp
				print "\r\n"
				p "************************"
				p "****party tako fixed ***"
				p "************************"
				if line == "\"Timeout!\""
					input.puts "#{result[0]}, #{sow[0]} #{result[1]}"
					print "#{result[0]}, #{sow[0]} #{result[1]}\n"
					db.commit
					return
				else
					print "#{result[0]}, #{sow[0]} #{result[1]}\n"
					db.commit
					return
				end
			end
		i = 0
		row = db.execute(tako_select)
		row.each do |result|
			select_tako = result[0]
			sow = db.execute("#{app_select} where tako_id = ?", select_tako)
			sow.each do |result2|
				select_app[i] = result2[1]
				i += 1
			end
		end
		db.commit
		select_app.uniq!
		i = 0
		while select_app[i] != nil
			join_app += "#{select_app[i]} "
			i += 1
		end
		
		msg = " QUERY COMMON_APP #{nick} #{join_app}"
		return msg
	end
end				
