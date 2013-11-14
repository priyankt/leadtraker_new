# Helper methods defined here can be accessed in any controller or view in the application

LeadTraker::Api.helpers do

	def get_user

		user = nil
		if env.has_key?("HTTP_X_AUTH_KEY") and env["HTTP_X_AUTH_KEY"].present?
			user = User.first(:auth_token => env["HTTP_X_AUTH_KEY"])
	    end

	end

	def get_setup_data(user)

		lead_sources = user.lead_sources.map { |ls| 
			{
				:id => ls.id, 
				:name => ls.name
			} 
		}

		lead_types = user.lead_types.map { |lt| {
				:id => lt.id,
				:name => lt.name,
				:lead_stages => lt.lead_stages.map{ |ls| {:id => ls.id, :name => ls.name}}
			} 
		}
		
		expenses = user.expenses.map { |e| 
			{
				:id => e.id, 
				:name => e.name, 
				:percent => e.percent, 
				:value => e.value, 
				:from => e.from, 
				:to => e.to, 
				:cap => e.cap
			} 
		}

		return {:lead_sources => lead_sources, :lead_types => lead_types, :expenses => expenses}

	end

end
