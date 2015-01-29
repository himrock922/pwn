=begin
SQL Table Create Module
=end
module CacheNumber
	# table create process
	def create_number
		sql = "create table Number (tako_id text, app_num integer)"
		return sql
	end
	######################

	# table data insert process
	def insert_number
		sql = "insert into Number values (?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_number
		sql = "delete from Number"
		return sql
	end
	######################

	# table data update process
	def update_number
		sql = "update Number"
		return sql
	end
	######################
	
	# table select process
	def select_number
		sql = "select * from Number"
		return sql
	end
	######################
	
end
