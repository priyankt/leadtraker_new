# Helper methods defined here can be accessed in any controller or view in the application

LeadTraker::Api.helpers do

	def get_user

		user = nil
		if env.has_key?("HTTP_X_AUTH_KEY") and env["HTTP_X_AUTH_KEY"].present?
			user = User.first(:auth_token => env["HTTP_X_AUTH_KEY"])
	    end

	end

end
