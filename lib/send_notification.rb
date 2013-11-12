class SendNotification
	#extend Resque::Plugins::ExponentialBackoff

	ANDROID_BATCH_LIMIT = 1000

	@queue = :leadtraker_send_notification

	# using exponential backoff as required by google gcm
	# it might blacklist of exponential backoff is not used
	#@backoff_strategy = [5, 50, 500, 5000]

	def self.perform(params)

		user_ids = params['user_ids'].join(',')
		android_registration_ids = repository(:default).adapter.select("SELECT android_token FROM users WHERE id in (#{user_ids}) and android_token is not null")
    	
    	android_response = ""
    	if android_registration_ids.length > 0

    		GCM.key = LeadTrakerConstants::ANDROID_SERVER_API_KEY

			data = {:alert => params['alert'], :type => params['type'], :param => params['id']}
			total = android_registration_ids.length
			start = 0

			while start < total
				# minus 1 since starting from 0
				last = [start + (ANDROID_BATCH_LIMIT - 1), total - 1].min
				chunk = android_registration_ids[start..last]
				response = GCM.send_notification( chunk, data )
				android_response = android_response + response.to_json
				start = last + 1
			end
		else
			puts "No registration ids supplied. Exiting.."
		end

		# code to send notification to ios
	
		# TODO: Error handling & other stuff

  	end

end