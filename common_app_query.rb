=begin
module CommonAppQuery module
=end

module CommonAppQuery
	def common_app_query(irc, db, app_select, tako_select, nick, cac_select, com_select, input, output)
		select_tako = ""
		select_app  = Array.new
		join_app    = ""
		msg         = ""

		db.execute("#{cac_select} left outer join ComNum on Cache.ikagent_ip = ComNum.ikagent_ip order by ComNum.app_num asc") do |row|
				next if row.empty? == true
				line = output.gets.chomp
				if line == "\"Timeout!\""
					print "\r\n"
					p "****party tako fixed ***"
					p "************************"
					p "************************"
					input.puts "#{row[0]}, #{row[1]} #{row[3]}"
					print "#{row[0]}, #{row[1]} #{row[3]}\n"
					return
				else
					return
				end
			end
	
		i = 0
		db.execute(tako_select) do |row|
			select_tako = row[0]
			db.execute("#{app_select} where tako_id = ?", select_tako) do |row2|
				
				select_app[i] = row2[1]
				i += 1
			end
		end
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
