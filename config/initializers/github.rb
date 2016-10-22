github = "#{Rails.root}/config/github.yml"
if File.exists? github
	config = YAML.load_file(github)
	config.each { |key, value| ENV[key] || ENV[key] = value.to_s }
end