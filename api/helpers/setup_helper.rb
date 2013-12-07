# Helper methods defined here can be accessed in any controller or view in the application

LeadTraker::Api.helpers do

	def get_setup_data(user, new_lead)

		data = {}
		data[:lead_sources] = user.lead_sources.map { |ls| 
			{
				:id => ls.id, 
				:name => ls.name
			} 
		}

		data[:lead_types] = user.lead_types.map { |lt| 
			{
				:id => lt.id,
				:name => lt.name,
				:lead_stages => lt.lead_stages.map{ |ls| {:id => ls.id, :name => ls.name}}
			} 
		}
		
		if new_lead.present? and new_lead != 0
			data[:expenses] = []
			#data[:sms_patterns] = []
			data[:contacts] = user.contacts.map { |c|
				{
					:id => c.id,
					:name => c.name,
					:company => c.company,
					:title => c.title,
					:address => c.address,
					:city => c.city,
					:state => c.state,
					:zip => c.zip,
					:email_addresses => c.email_addresses.map { |email|
						{
							:id => email.id,
							:value => email.value,
							:type => email.type
						}
					},
					:phone_numbers => c.phone_numbers.map { |phone|
						{
							:id => phone.id,
							:value => phone.value,
							:type => phone.type
						}
					}
				}
			}
		else
			data[:expenses] = user.expenses.map { |e| 
				{
					:id => e.id, 
					:name => e.name, 
					:percent => e.percent, 
					:value => e.value, 
					:from => format_dttm(e.from), 
					:to => format_dttm(e.to), 
					:cap => e.cap
				} 
			}
			#data[:sms_patterns] = get_sms_patterns(user, data[:lead_sources])
			data[:contacts] = []
		end

		return data

	end

	def get_sms_patterns(user, lead_sources)
		
		sms_patterns = []
		lead_sources.each do |ls|

		end

		return sms_patterns

	end

	def format_dttm(dttm)

		return (dttm.present? ? dttm.strftime('%d-%m-%Y') : nil)

	end

end
