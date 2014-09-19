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
	@@ping_pong = Thread.new do
		Thread.stop
		while @@msg = @@irc.read

			# server connection confirmation
			@@irc.pong "#{@@msg.split[1]}" if @@msg.split[0] == 'PING'
			################################

			## my channel join user information store hash table
			# join command for usrname extraction	
			if @@msg.split[1] =='JOIN'
				mc_user = @@msg.split(/\!\~/)
				mc_user[0].slice!(0)
				@@irc.whois mc_user[0]
				
			end
			################################################

			# extraction username for user information store 
			# hash table
			if @@msg.split[1] =='338'
				
				@@hash.store("#{@@msg.split[3]}", "#{@@msg.split[4]}")
				#hash table output
				p "hash table"
				@@hash.each do |key, val|
					p "#{key}: #{val}" 
				end
			end
			################################################
			################################################

			p @@msg
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
		@@ping_pong.join
		end
	end
IRC::new
