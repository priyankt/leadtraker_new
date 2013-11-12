class SendEmail
	
	@queue = :leadtraker_send_email

	#@retry_limit = 3
  	#@retry_delay = 120

	def self.perform(params)

		case params['mailer_name']
			when 'notifier'
				case params['email_type']
					when 'forgot_password'
						user = User.get(params['id'])
						new_password = params['new_password']
						LeadTraker::App.deliver(:notifier, :forgot_password, user, new_password)
					when 'new_user'
						user = User.get(params['id'])
						LeadTraker::App.deliver(:notifier, :new_user, user)
					else
						LeadTraker::App.deliver(:notifier, :invalid_email_type, params['email_type'])
				end
		end
		
	end

end