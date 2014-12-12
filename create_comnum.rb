=begin
SQL Table Create Module
=end
module CreateComNum
	# table create process
	def create_comnum
		sql = "create table ComNum (ikagent_id text, app_num integer)"
		return sql
	end
	######################

	# table data insert process
	def insert_comnum
		sql = "insert into ComNum values (?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_comnum
		sql = "delete from ComNum"
		return sql
	end
	######################

	# table data update process
	def update_comnum
		sql = "update ComNum"
		return sql
	end
	######################
	
	# table select process
	def select_comnum
		sql = "select * from ComNum"
		return sql
	end
	######################
	
end
