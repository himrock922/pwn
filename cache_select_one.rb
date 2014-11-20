=begin
SQL Table Create Module
=end
module CacheSelectOne
	# table create process
	def create_csone
		sql = "create table CacheSelectOne (tako_id text, tako_app text)"
		return sql
	end
	######################

	# table data insert process
	def insert_csone
		sql = "insert into CacheSelectOne values (?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_csone
		sql = "delete from CacheSelectOne"
		return sql
	end
	######################

	# table data update process
	def update_csone
		sql = "update from CacheSelectOne"
		return sql
	end
	######################
	
	# table select process
	def select_csone
		sql = "select * from CacheSelectOne"
		return sql
	end
	######################
	
end
