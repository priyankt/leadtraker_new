# Helper methods defined here can be accessed in any controller or view in the application

LeadTraker::Api.helpers do

	def get_user_leads(user)

		ret = []

        lead_users = LeadUser.all(:user_id => user.id, :status => :active, :order => [:created_at.desc])

		lead_users.each do |lu|

			agent_lu = get_agent_lu(lu, user)
            data = {}
            
            if lu.lead_type.present?
                data[:lead_type] = {
                    :id => lu.lead_type.id, 
                    :name => lu.lead_type.name
                }
            else
                data[:lead_type] = {
                    :id => nil, 
                    :name => nil
                }
            end

            data[:contact] = {
                :name => lu.primary_contact.name, 
                :phone_numbers => [{
                    :type => lu.primary_contact.phone_numbers.first.type, 
                    :value => lu.primary_contact.phone_numbers.first.value
                }],
                :email_addresses => [{
                    :type => lu.primary_contact.email_addresses.first.type, 
                    :value => lu.primary_contact.email_addresses.first.value
                }]
            }

            data[:dttm] = lu.created_at
            data[:prop_address] = "#{lu.lead.prop_address}, #{lu.lead.prop_city}" 
            if lu.current_stage.present?
                stage_id = lu.current_stage.lead_stage.id
                stage_name = lu.current_stage.lead_stage.name
            end
            data[:lead_stage] = {
                :id => (stage_id.present? ? stage_id : nil), 
                :name => (stage_name.present? ? stage_name : nil)
            }
            
            data[:agent_name] = lu.lead.agent.fullname

            if agent_lu.present?
                data[:agent_lead_type] = agent_lu.lead_type.name
            end
            
            data[:id] = lu.lead.id

            ret.push(data)
        end

        return ret
	end


	def get_agent_lu(lead_user, current_user)

		agent_lu = nil
		if lead_user.lead.agent.id != current_user.id
			agent_lu = LeadUser.first(:lead_id => lead_user.lead.id, :user_id => lead_user.lead.agent.id)
		end

		return agent_lu

	end

end
