# Seed add you the ability to populate your db.
# We provide you a basic shell for interaction with the end user.
# So try some code like below:
#
#   name = shell.ask("What's your name?")
#   shell.say name
#

# get base path to seed data
padrino_root = File.expand_path(File.join(File.dirname(__FILE__),'..'))


# POPULATE SMS PATTERNS
sms_patterns_count = SmsPattern.count()

if sms_patterns_count <= 0
	sms_patterns = JSON.parse File.read("public/sms_patterns.json")
	sms_patterns.each do |sp|
		SmsPattern.create(sp)
	end
end