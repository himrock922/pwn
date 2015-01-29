=begin
RandomTako module
=end
module RandomApp
	def random_app(db, input, output, cso_select)
		select_tako = ""
		select_app  = ""
		
		db.transaction
		row = db.execute("select tako_id from TAKO_List order by random()") 
		
		if row.empty? == true
			db.commit
			return
		end

		select_tako = row[0]

		row = db.execute("select tako_app from APP_List where tako_id = ? order by random()", select_tako[0])

		select_app = row[0]


		row = db.execute("#{cso_select} where tako_app = ? order by random()", select_app[0])	
		if row.empty? == true
			db.commit
			return
		end
		print "\r\n"
		p "*************************"
		p "****party tako fixed!****"
		p "*************************"
		row.each do |result|
			
			sow = db.get_first_row("select tako_mac from CacheTako where tako_id = ?", result[1])
			tow = db.get_first_row("select ikagent_ip from Cache where ikagent_id = ?", result[0])
			print "#{result[0]}, #{tow[0]}, #{result[1]} #{sow[0]} #{result[2]}\n"
		end
		db.commit
	end
end
