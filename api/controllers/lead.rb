LeadTraker::Api.controllers :lead do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    post '/' do

        begin
            lead = Lead.new
            lead.prop_address = params[:address] if params.has_key?('address')
            lead.prop_city = params[:city] if params.has_key?('city')
            lead.prop_state = params[:state] if params.has_key?('state')
            lead.prop_zip = params[:zip] if params.has_key?('zip')
            lead.reference = params[:reference] if params.has_key?('reference')

            lead_user = LeadUser.new(
                :lead_type_id => params[:lead_type_id], 
                :lead_source_id => params[:lead_source_id], 
                :user_id => @user.id
            )

            if params.has_key?('contacted') and params[:contacted]
                lead_user.contact_date = DateTime.now 
            end

            if params.has_key?('contact_id') and params[:contact_id].present?
                lead_user.primary_contact_id = params[:contact_id]
            end

            lead.agent = @user
            lead.lead_users << lead_user

            if lead.valid?

                Lead.transaction do
                    begin
                        lead.save
                    end
                end

                status 200
                ret = {:success => get_true(), :id => lead.id}
                
            end

        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}

        end

        return ret.to_json

    end

end
