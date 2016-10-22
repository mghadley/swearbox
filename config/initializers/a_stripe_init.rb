stripe = "#{Rails.root}/config/stripe.yml"
if File.exists? stripe
	config = YAML.load_file(stripe)
	config.each { |key, value| ENV[key] || ENV[key] = value.to_s }
end