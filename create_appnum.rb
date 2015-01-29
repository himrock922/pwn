=begin
SQL Table Create Module
=end
module CreateAppNum
	# table create process
	def create_appnum
		sql = "create table AppNum (tako_id text, app_num integer)"
		return sql
	end
	######################

	# table data insert process
	def insert_appnum
		sql = "insert into AppNum values (?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_appnum
		sql = "delete from AppNum"
		return sql
	end
	######################

	# table data update process
	def update_appnum
		sql = "update AppNum"
		return sql
	end
	######################
	
	# table select process
	def select_appnum
		sql = "select * from Appnum"
		return sql
	end
	######################
	
end
