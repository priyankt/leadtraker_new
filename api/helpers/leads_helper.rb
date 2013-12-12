# Helper methods defined here can be accessed in any controller or view in the application

LeadTraker::Api.helpers do

	def get_user_leads(user)

		ret = []

        lead_users = LeadUser.all(:user_id => user.id, :status => :active, :order => [:created_at.desc])

		lead_users.each do |lu|

			agent_lu = get_agent_lu(lu, user)
            data = {}
            
            if lu.lead_type.present?
                data[:lead_type] = lu.lead_type.format_for_app
            else
                data[:lead_type] = {:id => nil, :name => nil}
            end

            data[:contact] = lu.primary_contact.format_for_app

            data[:dttm] = lu.created_at
            data[:prop_address] = "#{lu.lead.prop_address}, #{lu.lead.prop_city}" 
            if lu.current_stage.present?
                data[:lead_stage] = lu.current_stage.format_for_app
            end
            
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
