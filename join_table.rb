=begin
SQL Table Join Module
=end
module JoinTable
	# table create process
	def join_table
		sql = "select TAKO_List.tako_id, TAKO_List.tako_mac, APP_List.tako_app from TAKO_List left outer join APP_List on TAKO_List.tako_id = APP_List.tako_id"
		return sql
	end
	######################
end
