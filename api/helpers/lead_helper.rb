# Helper methods defined here can be accessed in any controller or view in the application

LeadTraker::Api.helpers do

	def get_lead_from_params(params, current_user)

		lead = Lead.new
        lead.prop_address = params[:address] if params.has_key?('address')
        lead.prop_city = params[:city] if params.has_key?('city')
        lead.prop_state = params[:state] if params.has_key?('state')
        lead.prop_zip = params[:zip] if params.has_key?('zip')
        lead.reference = params[:reference] if params.has_key?('reference')
        lead.agent = current_user

        return lead

	end

	def get_lead_user_from_params(params, current_user)

        logger.debug params.inspect

		lead_user = LeadUser.new
		lead_user.lead_type_id = params[:lead_type_id] if params.has_key?('lead_type_id')
		lead_user.lead_source_id = params[:lead_source_id] if params.has_key?('lead_source_id')
		lead_user.user_id = current_user.id
		lead_user.secondary_contact_id = params[:secondary_contact_id] if params[:secondary_contact_id].present? and params[:secondary_contact_id].to_i > 0

        contact_id = params[:primary_contact_id]
        if contact_id.blank? and params[:contact_name].present?
            contact = Contact.new(:name => params[:contact_name], :user_id => @user.id)
            if params[:contact_email].present?
                contact.email_addresses << EmailAddress.new(:value => params[:contact_email], :type => :personal)
            end
            
            if params[:contact_number].present?
                contact.phone_numbers << PhoneNumber.new(:value => params[:contact_number], :type => :mobile)
            end

            if contact.valid?
                contact.save
            else
                raise CustomError.new(get_formatted_errors(contact.errors))
            end
            
            contact_id = contact.id
        end
        
        if contact_id.blank?
            raise CustomError.new(['Error while saving contact. Please try again.'])
        end

        lead_user.primary_contact_id = contact_id
        if params.has_key?('contacted') and params[:contacted]
            lead_user.contact_date = DateTime.now 
        end

        return lead_user

	end

end
