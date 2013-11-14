class SendEmail
	
	@queue = :leadtraker_send_email

	#@retry_limit = 3
  	#@retry_delay = 120

	def self.perform(params)
		puts params.inspect

		case params['mailer_name']
			when 'user_notifier'
				case params['email_type']
					when 'forgot_password'
						user = User.get(params['user_id'])
						new_password = params['new_passwd']
						LeadTraker::Api.deliver(:user_notifier, :forgot_password, user, new_password)
					when 'new_user'
						user = User.get(params['id'])
						LeadTraker::Api.deliver(:user_notifier, :new_user, user)
					else
						LeadTraker::Api.deliver(:user_notifier, :invalid_email_type, params['email_type'])
				end
		end
		
	end

end