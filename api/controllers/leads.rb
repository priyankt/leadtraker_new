LeadTraker::Api.controllers :leads do
    
    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    get '/' do

        ret = []
        
        lead_users = LeadUser.all(:user_id => @user.id, :status => :active)

        lead_users.each do |lu|

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
                }]
            }

            data[:dttm] = lu.created_at
            data[:prop_address] = lu.lead.prop_address
            if lu.current_stage.present?
                stage_id = lu.current_stage.lead_stage.id
                stage_name = lu.current_stage.lead_stage.name
            end
            data[:lead_stage] = {
                :id => (stage_id.present? ? stage_id : nil), 
                :name => (stage_name.present? ? stage_name : nil)
            }
            
            data[:agent_name] = lu.lead.agent.fullname

            ret.push(data)
        end

        return ret.to_json

    end

end
