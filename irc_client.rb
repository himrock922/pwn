=begin
IRC Client
=end

#IRC Client requrie library
gem "irc-socket"
require 'irc-socket'
require 'clockwork'

#ARGV loop require library
require 'optparse'

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
				# list mathod wakeup
				@@pwn_list.wakeup 
			end
			################################

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
				end
				# hash table clear
				@@channel_hash.clear
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
				#hash table output
				p "hash table"
				@@hash.each do |key, val|
					p "#{key}: #{val}" 
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
			# message output
			p msg
		end
	end

	# Pocket Warped Network construct for process
	@@pwn_list = Thread::fork do
		Thread::stop
		while true
			@@irc.list
			# until wakeup @@ping_pong sleep 
			sleep 3600
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
		if OPTS[:n] then @nick    = OPTS[:n] else @nick    = NICK end
		if OPTS[:u] then @user    = OPTS[:u] else @user    = USER end
		if OPTS[:c] then @channel = "#" + OPTS[:c] else @channel = CHANNEL end
		################################################################

		puts @server, @port, @nick, @user, @channel
		@@irc = IRCSocket.new(@server, @port)
		@@irc.connect

		if @@irc.connected?
			@@irc.nick "#{@nick}"
			@@irc.user "#{@user}", 0, "*", "I am #{@user}"
			@@irc.join "#{@channel}"
		end
		@@ping_pong.run
		@@pwn_list.run
		@@pwn_list.join
		@@ping_pong.join
		end
	end
IRC::new
