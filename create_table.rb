=begin
SQL Table Create Module
=end
module CreateTable
	# table create process
	def create_ikable
		sql = "create table Ikagent_List (ikagent_nick text, ikagent_addr text, tako_id text, tako_mac text, tako_app text, ikalue integer)"
		return sql
	end
	######################

	# table data insert process
	def insert_ikable
		sql = "insert into Ikagent_List values (?, ?, ?, ?, ?, ?)"
		return sql
	end
	######################
	
	# table delete process
	def delete_ikable
		sql = "delete from Ikagent_List"
		return sql
	end
	######################

	# table data update process
	def update_ikable
		sql = "update Ikagent_List"
		return sql
	end
	######################
	
	# table select process
	def select_ikable
		sql = "select * from Ikagent_List"
		return sql
	end
	######################
	
end
