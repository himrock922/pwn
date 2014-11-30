=begin
SQL Table Create Module
=end
module CreateComNum
	# table create process
	def create_comnum
		sql = "create table Comnum (ikagent_ip text, app_num text)"
		return sql
	end
	######################

	# table data insert process
	def insert_comnum
		sql = "insert into Comnum values (?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_comnum
		sql = "delete from Comnum"
		return sql
	end
	######################

	# table data update process
	def update_comnum
		sql = "update Comnum"
		return sql
	end
	######################
	
	# table select process
	def select_comnum
		sql = "select * from Comnum"
		return sql
	end
	######################
	
end
