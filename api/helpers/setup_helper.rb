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

		data[:lead_types] = user.lead_types.map { |lt| {
				:id => lt.id,
				:name => lt.name,
				:lead_stages => lt.lead_stages.map{ |ls| {:id => ls.id, :name => ls.name}}
			} 
		}
		
		if new_lead.present?
			data[:expenses] = []
			data[:contacts] = user.contacts.map { |c|
				{
					:id => c.id,
					:name => c.name,
					:subtitle => c.address
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
			data[:contacts] = []
		end

		return data

	end

	def format_dttm(dttm)

		return (dttm.present? ? dttm.strftime('%d-%m-%Y') : nil)

	end

end
