=begin
module CommonAppQuery module
=end

module CommonApp
	def common_app(db, cac_select, cat_select, app_select, cso_select, val_insert, val_update, val_select)
		# setting
		ikagent     = ""
		tako_id     = ""
		tako_app    = ""
		select_app  = Array.new
		p_select_app = Array.new
		i = 0
		db.transaction
		zow = db.execute(app_select)
		zow.each do |result4|
			select_app[i] = result4[1]
			i += 1
		end
		db.commit
		select_app.uniq!
		i = 0
		#######################
		db.transaction
		row = db.execute("select ikagent_id from Cache")
		row.each do |result|
			ikagent = result[0]
			i = 0
			#sow = db.execute("select tako_id from CacheTako where ikagent_id = ?", ikagent) 	
			#sow.each do |result2|
			#	tako_id = result2[0]
				#tow = db.execute("select tako_app from APP_List")
				#tow.each do |result3|
				#	tako_app = result3[0]
				#	pow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", tako_id, tako_app)
					pow = db.execute("#{cso_select} where ikagent_id = ?", ikagent)
					pow.each do |result4|
						p_select_app[i] = result4[2]
						i += 1
					end
				#end
			#end
			p_select_app.uniq!
			i = 0
			value = 0
			while select_app[i] != nil
				j = 0
				while p_select_app[j] != nil
					if select_app[i] == p_select_app[j] 
						value += 1
					end
					j += 1
				end
				i += 1
			end
			tmp = db.execute("#{val_select} where ikagent_id = ?", ikagent)
			if tmp.empty? == true
				#db.execute(val_insert, ikagent, i)
				db.execute(val_insert, ikagent, value)
			else
				#db.execute("#{val_update} set value = ? where ikagent_id = ?", i, ikagent)
				db.execute("#{val_update} set value = ? where ikagent_id = ?", value, ikagent)
			end
		end
		print "\r\n"
		p "*************************"
		p "****party tako fixed!****"
		p "*************************"
		
		row = db.execute("select * from Value order by value desc")
		if row.nil? == true
			db.commit
			return
		end
		
		row.each do |result|
			sow = db.get_first_row("select ikagent_ip from Cache where ikagent_id = ?", result[0])
			next if result[1].to_i < 1
			print "#{result[0]} #{sow[0]} #{result[1]}\n"
		end
		db.commit 
	end
end				
