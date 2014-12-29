=begin
SQL Table Create Module
=end
module CacheExact
	# table create process
	def create_exact
		sql = "create table CacheExact (ikagent_id text, p_tako_id text, o_tako_id text)"
		return sql
	end
	######################

	# table data insert process
	def insert_exact
		sql = "insert into CacheExact values (?, ?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_exact
		sql = "delete from CacheExact"
		return sql
	end
	######################

	# table data update process
	def update_exact
		sql = "update from CacheExact"
		return sql
	end
	######################
	
	# table select process
	def select_exact
		sql = "select * from CacheExact"
		return sql
	end
	######################
	
end
