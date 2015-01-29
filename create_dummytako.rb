#!/bin/ruby
	@@i = 0
	File.open("dummytako10.sh", "r") do |f|
		while line = f.gets
			
			tako_input = "NEW #{line}"
			File.open("dummytako_tmp.sh", "a+") do |file|
				file.puts "#{tako_input}"
				@@i += 1
			end
			break if @@i == 10
		end
	end

	
