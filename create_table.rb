=begin
SQL Table Create Module
=end
module CreateTable
	def create_ikable
		# table create process
		sql = "create table Ikagent_List (ikagent_cha text, ikagent_nick text, ikagent_addr text tako_id text, tako_mac text, tako_gc text)"
		######################
		return sql
	end
end
