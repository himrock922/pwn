=begin
SQL Table Create Module
=end
module CreateTakoble
	# table create process
	def create_takoble
		sql = "create table TAKO_List (tako_id text, tako_mac text)"
		return sql
	end
	######################

	# table data insert process
	def insert_takoble
		sql = "insert into TAKO_List values (?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_takoble
		sql = "delete from TAKO_List"
		return sql
	end
	######################

	# table data update process
	def update_takoble
		sql = "update TAKO_List"
		return sql
	end
	######################
	
	# table select process
	def select_takoble
		sql = "select * from TAKO_List"
		return sql
	end
	######################
	
end
