=begin
SQL Table Create Module
=end
module CreateCache
	# table create process
	def create_cache
		sql = "create table Cache (ikagent_id text, ikagent_ip text, created_at timestamp , updated_at timestamp)"
		return sql
	end
	######################

	# table data insert process
	def insert_cache
		sql = "insert into Cache values (?, ?, ?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_cache
		sql = "delete from Cache"
		return sql
	end
	######################

	# table data update process
	def update_cache
		sql = "update Cache"
		return sql
	end
	######################
	
	# table select process
	def select_cache
		sql = "select * from Cache"
		return sql
	end
	######################
	
end
