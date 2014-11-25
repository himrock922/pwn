class StreetPass
Signal.trap(:INT) {
		exit
}
	@@streetpass = Thread::fork do
		p "Timeout!"
		while input = gets.chomp
			print "#{input}"
			random = Random.new
			sleep random.rand(10..60)
			p "Timeout!"
		end
	end

	def initialize
		@@streetpass.run
		@@streetpass.join
	end
end
StreetPass::new
