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
			# server flooding channel information store for hash table
			when '322'
				@@channel_hash.store("#{msg.split[3]}", "#{msg.split[4]}")
			####################################################

			# channel hash table output
			when '323'
				p "channel hash table"
				@@channel_hash.each do |key, val|
					p "#{key}: #{val}"
					@@irc.privmsg "#{key}", " NEW-CHANNEL #{@@nick}"
				end

			######################################

			## my channel join user information store hash table
			# join command for usrname extraction	
			when 'JOIN'
				mj_user = msg.split(/\!\~/)
				mj_user[0].slice!(0)
				@@irc.whois mj_user[0]
			################################################

			# extraction username for user information store 
			# hash table
			when '338'
				@@hash.store("#{msg.split[3]}", "#{msg.split[4]}")
				p "new channel store complete!"
				#hash table output
				p "hash table"
				if $count > 0
					$count = 0
					@@hash.each do |key, val|
						p "#{key}: #{val}"
					end
				else
					@@hash.each do |key, val|
						p "#{key}: #{val}"
						@@irc.privmsg "#{key} UPD-IKAGENT #{@@nick}"
					end
				end
			################################################

			# my channel part user delete for hash table
			when 'PART'
				mp_user = msg.split(/\!\~/)
				mp_user[0].slice!(0)
				@@hash.delete("#{mp_user[0]}")
				# hash table output
				p "hash table"
				@@hash.each do |key, val|
					p "#{key}: #{val}"
				end
			################################################
			end
			################################################
			################################################

			# PRIVMSG process
			################################################
			################################################
			
			# if new ikagent join server session process
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'NEW-CHANNEL'
				@@irc.whois msg.split[5] # new ikagent whois command process
			end
			###############################################

			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'UPD-IKAGENT'
				$count = 1
				@@irc.whois msg.split[5]
			end
			# if disconnect ikagent server session process
			if msg.split[1] == 'PRIVMSG' && msg.split[4] == 'DEL-CHANNEL'
				@@channel_hash.delete("#{msg.split[5]}") # channel table disconnect ikagent delete

				@@hash.delete("#{msg.split[6]}") # hash table disconnect ikagent delete
				# such table output
				p "delete complete"
				p "channel table"
				@@channel_hash.each do |key, val|
					p "#{key}: #{val}"
				end
				p "hash table"
				@@hash.each do |key, val|
					p "#{key}: #{val}"
				end
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
			
	@@writen = Thread::fork do
		Thread::stop
		while input = gets.chomp
			if /exit/i =~ input
				@@channel_hash.each do |key, val|
					@@irc.privmsg "#{key}", " DEL-CHANNEL #{@@channel} #{@@nick}"
				end
				exit
			else
				next
			end
		end
	end
	
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
				opt.on('-s SERVER', '--server', 'server')                                         {|v| OPTS[:s] = v}
				opt.on('-p PORT', '--port', 'port')                                               {|v| OPTS[:p] = v}
				opt.on('-n NICK', '--nick', 'nick')						  {|v| OPTS[:n] = v}
				opt.on('-u USER', '--user', 'user')						  {|v| OPTS[:u] = v}
				opt.on('-c CHANNEL', '--channel', 'channel')					  {|v| OPTS[:c] = v}
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
		if OPTS[:s] then @server  = OPTS[:s] else @server  = SERVER end
		if OPTS[:p] then @port    = OPTS[:p] else @port    = PORT end
		if OPTS[:n] then @@nick    = OPTS[:n] else @@nick    = NICK end
		if OPTS[:u] then @user    = OPTS[:u] else @user    = USER end
		if OPTS[:c] then @@channel = "#" + OPTS[:c] else @@channel = CHANNEL end
		################################################################

		puts @server, @port, @@nick, @user, @@channel
		@@irc = IRCSocket.new(@server, @port)
		@@irc.connect

		if @@irc.connected?
			@@irc.nick "#{@@nick}"
			@@irc.user "#{@user}", 0, "*", "I am #{@user}"
			@@irc.join "#{@@channel}"
			@@irc.mode "#{@@channel}", "-n"
		end
		@@irc.list
		@@ping_pong.run
		@@writen.run
		@@pwn_poxpr.run
		@@writen.join
		@@ping_pong.join
		@@pwn_poxpr.join
		end
	end
IRC::new
