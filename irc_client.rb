=begin
IRC Client
=end

#IRC Client requrie library
gem "irc-socket"
require 'irc-socket'

#ARGV loop require library
require 'optparse'

require 'open3'

#default irc server setup
SERVER = "bsd-himrock922.jaist.ac.jp"
PORT = 6667
CHANNEL ="#ikachang"
@eol = "\r\n"
NICK = "himrock922"
USER = "him"
OPTS = {}

class IRC
Signal.trap(:INT) {
	@@channel_hash.each_key do |key|
		@@irc.privmsg "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick}" # send DEL-CHANNEL message (hash table for value delete)
	end
	exit
}
@@hash = {}
@@channel_hash = {}
	# while ping_pong and hash table process

	@@ping_pong = Thread::fork do
		Thread::stop
		while msg = @@irc.read

			# server connection confirmation
			if msg.split[0] == 'PING'
				@@irc.pong "#{msg.split[1]}"
				
			end
			################################

			# if msg.split[1] only process
			####################################################
			####################################################
			case msg.split[1]

			# private message (NEW) for channel name extract
			when '319'
				channel_tmp = msg.split(/\:\@/) # such message to :@ extract 
				channel_hash_tmp = {} # temporary channel table
				channel_hash_tmp.store("#{channel_tmp[1]}", 1)
				@@channel_hash.update(channel_hash_tmp) # channel table update
			##################################################

			# server flooding channel information store for hash table
			when '322'
				@@channel_hash.store("#{msg.split[3]}", "#{msg.split[4]}")
			####################################################

			# channel hash table output
			when '323'
				p "channel hash table"
				@@channel_hash.each_key do |key|
					p "#{key}"
					@@irc.privmsg "#{key}", " NEW-CHANNEL #{@@nick} #{@@ip} #{@@channel}" # other ikagent send private message about own information (NEW)
				end

			######################################

			## my channel join user information store hash table
			# join command for usrname extraction	
			when 'JOIN'
				mj_user = msg.split(/\!\~/)
				mj_user[0].slice!(0)
				@@irc.whois "#{mj_user[0]}"
			################################################

			# extraction username for user information store 
			# hash table
			when '338'
				@@hash.store("#{msg.split[3]}", "#{msg.split[4]}")
				@@ip = "#{msg.split[4]}"
			################################################

			# my channel part user delete for hash table
			when 'PART'
				mp_user = msg.split(/\!\~/)
				mp_user[0].slice!(0)
				@@hash.delete("#{mp_user[0]}")
				# hash table output
				p "hash table"
				@@hash.each do |key, val|
					p "#{key} : #{val}"
				end
			################################################
			end
			################################################
			################################################

			# PRIVMSG process
			################################################
			################################################
			
			# if new ikagent join server session process
			################################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'NEW-CHANNEL'
				@@hash.store("#{msg.split[5]}", "#{msg.split[6]}")
				@@channel_hash.store("#{msg.split[7]}", "1")
				@@channel_hash.each_key do |c_key|
					@@irc.privmsg "#{c_key}", " UPD-IKAGENT #{@@nick} #{@@ip}" # other ikagent private message about own information (UPDATE)
				end
			end
			###############################################

			# if update ikagent message process
			###############################################
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'UPD-IKAGENT'
				tmp_hash = {} # templary hash table
				tmp_hash.store("#{msg.split[5]}", "#{msg.split[6]}")
				@@hash.update(tmp_hash) # stable hash table update
				p ""
				p "channel table"
				@@channel_hash.each_key do |key|
					p "#{key}"
				end

				p ""
				p "hash table"
				@@hash.each do |key, val|
					p "#{key} : #{val}"
				end
				@@ikagent_stable.wakeup
			end
			###############################################

			# if disconnect ikagent server session process
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'DEL-CHANNEL'
				@@channel_hash.delete("#{msg.split[5]}") # channel table disconnect ikagent delete

				@@hash.delete("#{msg.split[6]}") # hash table disconnect ikagent delete
				# such table output
				p "delete complete"
				p ""
				p "channel table"
				@@channel_hash.each_key do |key|
					p "#{key}"
				end
				p ""
				p "hash table"
				@@hash.each do |key, val|
					p "#{key} : #{val}"
				end
				@@ikagent_stable.wakeup
			end
 			###############################################

			###############################################
			###############################################

			# message output
			p msg
		end
	end
	#########################################
	#########################################
	#########################################

	# Communication between nodes for process
	#########################################	
	@@pwn_poxpr = Thread::fork do
		Thread::stop
			# Collaboration with communication between nodes program
			poxpr_input, poxpr_output = Open3.popen3('./poxpr -c 1 -X')
			# Collaboration program stdout
			poxpr_output.each do |core_output|
				p core_output
		end
	end
	##################################################
			
	# thread write process
	#################################################
	@@writen = Thread::fork do
		Thread::stop
		while input = gets.chomp # wait stdin
			if /exit/i =~ input # program exit process
				@@channel_hash.each_key do |key|
					@@irc.privmsg "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick}" # send DEL-CHANNEL message (hash table for value delete)
				end
				exit
			else
				next # other continue
			end
		end
	end
	##########################################################

	# ikagent list store process
	##########################################################
	@@ikagent_stable = Thread::fork do
		Thread::stop
		while true
			sleep # sleep until wakeup
				# temporary array define
				channel_array = Array.new
				nick_array    = Array.new
				ip_array       = Array.new
				##########################

				@@channel_hash.each_key do |key|
					channel_array.push (key) # channel push to array
				end

				@@hash.each do |key, val|
					nick_array.push (key) # nick to array
					ip_array.push (val) # ip address to array
				end
			@@ikagent_list =  channel_array.zip(nick_array, ip_array) # multiple array zip (channel name, nick name, ip address)

			p @@ikagent_list #ikagent_list output
		end
	end
	##########################################################

	# start
	##########################################################
	def initialize
		OptionParser::new do |opt|
			begin
				# program name output
				opt.program_name = File.basename($0)
				opt.version = '0.0.1'
				#####################	

				# Usage output		
				opt.banner = "Usage: #{opt.program_name} [options] options support command input"
				#####################

				# Examples output
				opt.separator ''
				opt.separator 'Examples:'
				opt.separator "    % #{opt.program_name} -s example.jp -p 6667 -n himrock922 -u himrock -c ikachang"
				#####################
			
				# Specific Options Usage output
				opt.separator ''
				opt.separator 'Specific options:'
				opt.on('-s SERVER', '--server', 'server')    {|v| OPTS[:s] = v}
				opt.on('-p PORT', '--port', 'port')          {|v| OPTS[:p] = v}
				opt.on('-n NICK', '--nick', 'nick')          {|v| OPTS[:n] = v}
				opt.on('-u USER', '--user', 'user')          {|v| OPTS[:u] = v}
				opt.on('-c CHANNEL', '--channel', 'channel') {|v| OPTS[:c] = v}
				############################################
			
				# Options Usage output
				opt.separator ''
				opt.separator 'Common options:'

				opt.on_tail('-h', '--help', 'show this help 
				     message end exit') do
					puts opt
					exit
				end
				############################################
	
				opt.parse!(ARGV)
				rescue => e
					puts "ERROR: #{e}.\nSee #{opt}"
					exit
				end
			end
	
		#Each option store
		if OPTS[:s] then @server = OPTS[:s] else @server = SERVER end
		if OPTS[:p] then @port = OPTS[:p] else @port = PORT end
		if OPTS[:n] then @@nick = OPTS[:n] else @@nick = NICK end
		if OPTS[:u] then @user = OPTS[:u] else @user = USER end
		if OPTS[:c] then @@channel = "#" + OPTS[:c] else @@channel = CHANNEL end
		################################################################

		# such paramater output
		puts @server, @port, @@nick, @user, @@channel
		
		# irc socket create
		@@irc = IRCSocket.new(@server, @port)
		# irc server connect
		@@irc.connect

		# connection process
		if @@irc.connected?
			@@irc.nick "#{@@nick}" # nickname decide
			@@irc.user "#{@user}", 0, "*", "I am #{@user}" # hello message 
			@@irc.join "#{@@channel}" # channel name decide
			@@irc.mode "#{@@channel}", "-n" # mode change
		end
		###################################################

		# ikagent start
		#######################
		######################

		# thread run
		#######################
		@@irc.whois @@nick
		@@irc.list # channel list output
		@@ping_pong.run # server message read process
		@@writen.run # ikagent message write process
		@@pwn_poxpr.run # poxpr process
		@@ikagent_stable.run # ikagent_stable process
		#######################
		
		# such thread join
		########################
		@@writen.join
		@@ping_pong.join
		@@pwn_poxpr.join
		@@ikagent_stable.join
		########################
		
		########################
		########################
		end
	end
IRC::new
