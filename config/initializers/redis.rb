uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/" )
puts "****************************", uri, ENV["REDISTOGO_URL"]
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
