=begin
SQL Table Create Module
=end
module CreateValue
	# table create process
	def create_value
		sql = "create table Value (ikagent_ip text, value integer)"
		return sql
	end
	######################

	# table data insert process
	def insert_value
		sql = "insert into Value values (?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_value
		sql = "delete from Value"
		return sql
	end
	######################

	# table data update process
	def update_value
		sql = "update Value"
		return sql
	end
	######################
	
	# table select process
	def select_value
		sql = "select * from Value"
		return sql
	end
	######################
	
end
