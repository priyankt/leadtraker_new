LeadTraker::Api.controllers :leads do
    
    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    get '/' do

        ret = []
        data = {}

        lead_users = LeadUser.all(:user_id => @user.id, :status => :active)
        lead_users.each do |lu|
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
            data[:address] = lu.lead.prop_address
            data[:lead_stage] = {
                :id => lu.current_stage.lead_stage.id, 
                :name => lu.current_stage.lead_stage.id
            }

            ret.push(data)
        end

        return ret.to_json

    end

end
