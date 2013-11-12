# Helper methods defined here can be accessed in any controller or view in the application

LeadTraker::Api.helpers do
	
	# format error before sending back to app
	def get_formatted_errors(errors)

		err_list = Array.new()
	  	errors.each do |e|
	  		err_list.push(e.pop)
	  	end

  		return err_list

	end

	def get_lead_sources(user_type)

		filepath = "public/lender_lead_sources.json"
		if user_type == :agent
			filepath = "public/agent_lead_sources.json"
		end

		leadSourcesHash = nil
		File.open(filepath, "r").each_line do |line|
  			leadSourcesHash = JSON.parse line
		end

		return leadSourcesHash

	end

	def get_lead_types(user_type)

		filepath = "public/lender_lead_types.json"
		if user_type == :agent
			filepath = "public/agent_lead_types.json"
		end

		leadTypesHash = nil
		File.open(filepath, "r").each_line do |line|
  			leadTypesHash = JSON.parse line
		end

		return leadTypesHash

	end

end
