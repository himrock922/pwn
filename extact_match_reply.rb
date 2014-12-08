=begin
module CommonAppQuery module
=end

module ExtactMatchReply
	def extact_match_reply(irc, db, app_select, apn_select, tako_select, nick, ip, s_nick, s_app)
		#######################
		i = 0
		select_tako = ""
		select_mac  = ""

		while s_app.split[i] != nil
			i += 1	
		end

		case i
		when 1
			db.execute("#{apn_select} where app_num = ? order by random()", 1) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					if sow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end	
				end
			end
		
		when 2
			db.execute("#{apn_select} where app_num = ? order by random()", 2) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					if tow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 3 
			db.execute("#{apn_select} where app_num = ? order by random()", 3) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					if uow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 4 
			db.execute("#{apn_select} where app_num = ? order by random()", 4) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					
					if vow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 5 
			db.execute("#{apn_select} where app_num = ? order by random()", 5) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					if wow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 6 
			db.execute("#{apn_select} where app_num = ? order by random()", 6) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					if xow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 7 
			db.execute("#{apn_select} where app_num = ? order by random()", 7) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					if yow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 8 
			db.execute("#{apn_select} where app_num = ? order by random()", 8) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					next if yow.empty? == true
					zow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[7])
					if zow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 9 
			db.execute("#{apn_select} where app_num = ? order by random()", 9) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					next if yow.empty? == true
					zow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[7])
					next if zow.empty? == true
					aow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[8])
					if aow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 10 
			db.execute("#{apn_select} where app_num = ? order by random()", 10) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					next if yow.empty? == true
					zow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[7])
					next if zow.empty? == true
					aow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[8])
					next if aow.empty? == true
					bow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[9])
					if bow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 11 
			db.execute("#{apn_select} where app_num = ? order by random()", 11) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					next if yow.empty? == true
					zow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[7])
					next if zow.empty? == true
					aow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[8])
					next if aow.empty? == true
					bow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[9])
					next if bow.empty? == true
					cow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[10])
					if cow.empty? == true
						next
					else
						select_tako = row[0]
						break
					end
				end
			end
		when 12 
			db.execute("#{apn_select} where app_num = ? order by random()", 12) do |row|
				if row.empty? == true
					return
				else
					sow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[0])
					next if sow.empty? == true
					tow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[1])
					next if tow.empty? == true
					uow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[2])
					next if uow.empty? == true
					vow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[3])
					next if vow.empty? == true
					wow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[4])
					next if wow.empty? == true
					xow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[5])
					next if xow.empty? == true
					yow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[6])
					next if yow.empty? == true
					zow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[7])
					next if zow.empty? == true
					aow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[8])
					next if aow.empty? == true
					bow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[9])
					next if bow.empty? == true
					cow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[10])
					next if cow.empty? == true
					dow = db.execute("#{app_select} where tako_id = ? and tako_app = ?", row[0], s_app.split[11])
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
		db.execute("#{tako_select} where tako_id = ?", select_tako) do |result|
			select_mac = result[1]
			break
		end

		msg = " REPLY BEST_MATCH #{nick} #{ip} #{select_tako} #{select_mac}"
		irc.notice "#{s_nick}", "#{msg}"
	end
end				
