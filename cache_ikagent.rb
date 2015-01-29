=begin
SQL Table Create Module
=end
module CacheIkagent
	# table create process
	def create_cache
		sql = "create table Cache (ikagent_id text, ikagent_ip text, creat_date timestamp, update_date timestamp)"
		return sql
	end
	######################

	# table data insert process
	def insert_cache
		sql = "insert into Cache values (?, ?, (datetime('now', 'localtime')), (datetime('now', 'localtime')))"
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
