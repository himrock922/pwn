=begin
module CommonAppQuery module
=end

module CommonApp
	def common_app(db, cac_select, cat_select, app_select, cso_select, val_insert, val_update, val_select)
		# setting
		select_tako = ""
		join_tako   = ""
		select_app  = Array.new
		i = 0
		value = 0
		#######################
		db.execute(cac_select) do |sow|
			ip = ""
			i = 0
			db.execute("#{cat_select} where ikagent_ip = ?", sow[1]) do |tow|
				db.execute(app_select) do |row|
					db.execute("#{cso_select} where tako_id = ? and tako_app = ?", tow[1], row[1]) do |pow|
						i += 1
					end
				end
			end
			tmp = db.execute("#{val_select} where ikagent_ip = ?", sow[1])
			if tmp.empty? == true
				db.execute(val_insert, sow[1], i)
			else
				db.execute("#{val_update} set value = ? where ikagent_ip = ?", i, sow[1])
			end
		end
		print "\r\n"
		p "*************************"
		p "****party tako fixed!****"
		p "*************************"
		db.execute("select * from Cache left outer join Value on Cache.ikagent_ip = Value.ikagent_ip") do |row|
			print "#{row[0]} #{row[1]} #{row[5]}\n"
		end
	end
end				
