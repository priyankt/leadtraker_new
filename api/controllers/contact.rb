LeadTraker::Api.controllers :contact do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    post '/' do

        begin

            contact = Contact.new
            contact.name = params['name']
            contact.company = params['company']
            contact.title = params['title']
            contact.address = params['address']
            contact.city = params['city']
            contact.state = params['state']
            contact.zip = params['zip']
            contact.user_id = @user.id

            phone_numbers = JSON.parse params['phone_numbers']
            phone_numbers.each do |phone|
                contact.phone_numbers << PhoneNumber.new(:type => phone['type'].downcase.to_sym, :value => phone['value'])
            end

            email_addresses = JSON.parse params['email_addresses']
            email_addresses.each do |email|
                contact.email_addresses << EmailAddress.new(:type => email['type'].downcase.to_sym, :value => email['value'])
            end

            if contact.valid?
                contact.save
                status 201
                ret = contact.format_for_app
            else
                raise CustomError.new(get_formatted_errors(contact.errors))
            end
            
        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}
            
        end

        return ret.to_json

    end

    put '/:id' do

        begin

            contact = @user.contacts.get(params[:id])
            if contact.blank?
                raise CustomError.new(['Invalid contact. Please try again.'])
            end

            contact_hash = {}
            contact_hash['name'] = params['name'] if params.has_key?('name')
            contact_hash['company'] = params['company'] if params.has_key?('company')
            contact_hash['title'] = params['title'] if params.has_key?('title')
            contact_hash['address'] = params['address'] if params.has_key?('address')
            contact_hash['city'] = params['city'] if params.has_key?('city')
            contact_hash['state'] = params['state'] if params.has_key?('state')
            contact_hash['zip'] = params['zip'] if params.has_key?('zip')

            contact.update(contact_hash)

            phone_numbers = JSON.parse params['phone_numbers']
            phone_numbers.each do |phone|
                if phone['id'].present? and phone['id'] > 0
                    p = contact.phone_numbers.get(phone['id'])
                    p.update(:type => phone['type'].downcase.to_sym, :value => phone['value'])
                else
                    p = PhoneNumber.new(:type => phone['type'].downcase.to_sym, :value => phone['value'], :contact_id => contact.id)
                    p.save
                end
            end

            email_addresses = JSON.parse params['email_addresses']
            email_addresses.each do |email|
                if email['id'].present? and email['id'] > 0
                    e = contact.email_addresses.get(email['id'])
                    e.update(:type => email['type'].downcase.to_sym, :value => email['value'])
                else
                    e = EmailAddress.new(:type => email['type'].downcase.to_sym, :value => email['value'], :contact_id => contact.id)
                    e.save
                end
            end

            status 200
            ret = contact.format_for_app

        rescue CustomError => ce

            status 400
            ret = {:success => false, :errors => ce.errors}
            
        end

        return ret.to_json

    end

end
