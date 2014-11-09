=begin
SQL Table Create Module
=end
module CreateAppble
	# table create process
	def create_appble
		sql = "create table APP_List (tako_id text, tako_app text)"
		return sql
	end
	######################

	# table data insert process
	def insert_appble
		sql = "insert into APP_List values (?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_appble
		sql = "delete from APP_List"
		return sql
	end
	######################

	# table data update process
	def update_appble
		sql = "update APP_List"
		return sql
	end
	######################
	
	# table select process
	def select_appble
		sql = "select * from APP_List"
		return sql
	end
	######################
	
end
