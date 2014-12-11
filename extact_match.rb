=begin
module CommonAppQuery module
=end

module ExtactMatch
	def extact_match(db, tako_id, app_select, num_select, cso_select)
		#######################
		i = 0
		s_app = Array.new
		select_tako = ""
		db.execute("select tako_app from APP_List where tako_id = ?", tako_id) do |row|
			s_app[i] = row[0]
			i += 1
		end
		case i
		when 1
			db.execute("#{num_select} where app_num = ? order by random()", 1) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					if sow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end	
				end
			end
		
		when 2
			db.execute("#{num_select} where app_num = ? order by random()", 2) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					next if sow.empty? == true
					tow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[1])
					if tow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 3 
			db.execute("#{num_select} where app_num = ? order by random()", 3) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					next if sow.empty? == true
					tow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[1])
					next if tow.empty? == true
					uow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[2])
					if uow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 4 
			db.execute("#{num_select} where app_num = ? order by random()", 4) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					next if sow.empty? == true
					tow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[1])
					next if tow.empty? == true
					uow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[2])
					next if uow.empty? == true
					vow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[3])
					
					if vow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 5 
			db.execute("#{num_select} where app_num = ? order by random()", 5) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					next if sow.empty? == true
					tow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[1])
					next if tow.empty? == true
					uow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[2])
					next if uow.empty? == true
					vow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[3])
					next if vow.empty? == true
					wow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[4])
					if wow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 6 
			db.execute("#{num_select} where app_num = ? order by random()", 6) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					next if sow.empty? == true
					tow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[1])
					next if tow.empty? == true
					uow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[2])
					next if uow.empty? == true
					vow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[3])
					next if vow.empty? == true
					wow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[4])
					next if wow.empty? == true
					xow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[5])
					if xow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 7 
			db.execute("#{num_select} where app_num = ? order by random()", 7) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					next if sow.empty? == true
					tow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[1])
					next if tow.empty? == true
					uow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[2])
					next if uow.empty? == true
					vow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[3])
					next if vow.empty? == true
					wow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[4])
					next if wow.empty? == true
					xow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[5])
					next if xow.empty? == true
					yow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[6])
					if yow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 8 
			db.execute("#{num_select} where app_num = ? order by random()", 8) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					next if sow.empty? == true
					tow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[1])
					next if tow.empty? == true
					uow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[2])
					next if uow.empty? == true
					vow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[3])
					next if vow.empty? == true
					wow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[4])
					next if wow.empty? == true
					xow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[5])
					next if xow.empty? == true
					yow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[6])
					next if yow.empty? == true
					zow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[7])
					if zow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 9 
			db.execute("#{num_select} where app_num = ? order by random()", 9) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					next if sow.empty? == true
					tow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[1])
					next if tow.empty? == true
					uow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[2])
					next if uow.empty? == true
					vow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[3])
					next if vow.empty? == true
					wow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[4])
					next if wow.empty? == true
					xow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[5])
					next if xow.empty? == true
					yow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[6])
					next if yow.empty? == true
					zow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[7])
					next if zow.empty? == true
					aow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[8])
					if aow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 10 
			db.execute("#{num_select} where app_num = ? order by random()", 10) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					next if sow.empty? == true
					tow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[1])
					next if tow.empty? == true
					uow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[2])
					next if uow.empty? == true
					vow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[3])
					next if vow.empty? == true
					wow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[4])
					next if wow.empty? == true
					xow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[5])
					next if xow.empty? == true
					yow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[6])
					next if yow.empty? == true
					zow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[7])
					next if zow.empty? == true
					aow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[8])
					next if aow.empty? == true
					bow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[9])
					if bow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 11 
			db.execute("#{num_select} where app_num = ? order by random()", 11) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					next if sow.empty? == true
					tow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[1])
					next if tow.empty? == true
					uow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[2])
					next if uow.empty? == true
					vow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[3])
					next if vow.empty? == true
					wow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[4])
					next if wow.empty? == true
					xow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[5])
					next if xow.empty? == true
					yow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[6])
					next if yow.empty? == true
					zow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[7])
					next if zow.empty? == true
					aow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[8])
					next if aow.empty? == true
					bow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[9])
					next if bow.empty? == true
					cow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[10])
					if cow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 12 
			db.execute("#{num_select} where app_num = ? order by random()", 12) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[0])
					next if sow.empty? == true
					tow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[1])
					next if tow.empty? == true
					uow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[2])
					next if uow.empty? == true
					vow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[3])
					next if vow.empty? == true
					wow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[4])
					next if wow.empty? == true
					xow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[5])
					next if xow.empty? == true
					yow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[6])
					next if yow.empty? == true
					zow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[7])
					next if zow.empty? == true
					aow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[8])
					next if aow.empty? == true
					bow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[9])
					next if bow.empty? == true
					cow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[10])
					next if cow.empty? == true
					dow = db.execute("#{cso_select} where tako_id = ? and tako_app = ?", row[0], s_app[11])
					if dow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		end

		return if select_tako.empty? == true
		db.execute("select Cache.ikagent_id, Cache.ikagent_ip, CacheTako.tako_id, CacheTako.tako_mac from Cache left outer join CacheTako on Cache.ikagent_id == CacheTako.ikagent_id where CacheTako.tako_id = ?", select_tako) do |row|
			print "\r\n"
			p "*************************"
			p "****party tako fixed!****"
			p "*************************"
			print "#{row[0]} #{row[1]} #{row[2]} #{row[3]}\n"
		end
	end
end				
