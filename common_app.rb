=begin
module CommonAppQuery module
=end

module CommonApp
	def common_app(db, cac_select, cat_select, app_select, cso_select, val_insert, val_update, val_select)
		# setting
		ikagent     = ""
		tako_id     = ""
		tako_app    = ""
		i = 0
		#######################
		db.execute("select ikagent_id from Cache") do |sow|
			ikagent = sow[0]
			i = 0
			db.execute("select tako_id from CacheTako where ikagent_id = ?", ikagent) do |tow|
				tako_id = tow[0]
				db.execute("select tako_app from APP_List") do |row|
				tako_app = row[0]
					db.execute("#{cso_select} where tako_id = ? and tako_app = ?", tako_id, tako_app) do |pow|
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
