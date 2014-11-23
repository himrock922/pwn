class StreetPass
Signal.trap(:INT) {
		exit
}
	@@streetpass = Thread::fork do
		while input = gets.chomp
			print "#{input}"
			random = Random.new
			sleep random.rand(10..60)
			print "Timeout!"
		end
	end

	def initialize
		@@streetpass.run
		@@streetpass.join
	end
end
StreetPass::new
