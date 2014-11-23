class StreetPass
Signal.trap(:INT) {
		exit
}
	@@streetpass = Thread::fork do
		print "StreetPassOK!"
		while input = gets.chomp
			print "#{input}"
			sleep 20
			print "Timeout!"
		end
	end

	def initialize
		@@streetpass.run
		@@streetpass.join
	end
end
StreetPass::new
