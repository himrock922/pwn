=begin
module CommonAppQuery module
=end

module CommonApp
	def common_app(db, cac_select, cat_select, app_select, cso_select, val_insert, val_update, val_select)
		# setting
		select_tako = ""
		join_tako   = ""
		ikagent     = ""
		select_app  = Array.new
		i = 0
		value = 0
		#######################
		db.execute("select ikagent_id from Cache") do |sow|
			ikagent = sow[0]
			i = 0
			db.execute("#{cat_select} where ikagent_id = ?", ikagent) do |tow|
				db.execute(app_select) do |row|
					db.execute("#{cso_select} where tako_id = ? and tako_app = ?", tow[1], row[1]) do |pow|
						i += 1
					end
				end
			end
			tmp = db.execute("#{val_select} where ikagent_id = ?", ikagent)
			if tmp.empty? == true
				db.execute(val_insert, ikagent, i)
			else
				db.execute("#{val_update} set value = ? where ikagent_id = ?", i, ikagent)
			end
		end
		print "\r\n"
		p "*************************"
		p "****party tako fixed!****"
		p "*************************"
		db.execute("select Cache.ikagent_id, ikagent_ip, value from Cache left outer join Value on Cache.ikagent_id = Value.ikagent_id") do |row|
			print "#{row[0]} #{row[1]} #{row[2]}\n"
		end
	end
end				
