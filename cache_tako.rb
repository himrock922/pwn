=begin
SQL Table Create Module
=end
module CacheTako
	# table create process 
	def create_cako
		sql = "create table CacheTako (ikagent_id text, tako_id text, tako_mac text)"
		return sql
	end
	######################

	# table data insert process
	def insert_cako
		sql = "insert into CacheTako values (?, ?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_cako
		sql = "delete from CacheTako"
		return sql
	end
	######################

	# table data update process
	def update_cako
		sql = "update from CacheTako"
		return sql
	end
	######################
	
	# table select process
	def select_cako
		sql = "select * from CacheTako"
		return sql
	end
	######################
	
end
