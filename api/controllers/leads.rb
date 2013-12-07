LeadTraker::Api.controllers :leads do
    
    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    get '/' do

        ret = get_user_leads(@user)

        return ret.to_json

    end

    # Set lead type for leads
    put '/update' do

        begin

            leads = JSON.parse params[:leads]
            leads.each do |l|
                lead_user = LeadUser.first(:lead_id => l['lead_id'], :user_id => @user.id)
                if l['lead_type_id'].present? and l['lead_type_id'] != 0
                    lead_user.update(:lead_type_id => l['lead_type_id'])
                else
                    lead_user.update(:status => :inactive)
                end
            end

            status 200
            ret = get_user_leads(@user)
            
        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}

        end

        return ret.to_json

    end

end
