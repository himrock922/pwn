=begin
RandomTako module
=end
module RandomTako
	def random_tako(db, input, output, cso_select)
		select_tako = ""
		select_app  = ""
		

		row = db.execute("select tako_id from TAKO_List order by random()") 
		
		return if row.empty? == true
		select_tako = row[0]

		row = db.execute("select tako_app from APP_List where tako_id = ? order by random()", select_tako[0])
		select_app = row[0]

		db.execute("#{cso_select} where tako_app = ? order by random()", select_app[0])	do |row|	
			if row.empty? == true
				return
			else
			db.execute("select * from CacheTako where tako_id = ?", row[0]) do |sow|
				db.execute("select * from Cache where ikagent_id = ?", sow[0]) do |tow|
					print "\r\n"
					p "*************************"
					p "****party tako fixed!****"
					p "*************************"
					print "#{tow[0]}, #{tow[1]}, #{sow[1]} #{sow[2]} #{row[1]}\n"
					end
				end
			end
		end
	end
end
