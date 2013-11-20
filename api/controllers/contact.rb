LeadTraker::Api.controllers :contact do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    post '/' do

        puts params.inspect

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
                ret = {:success => true, :id => contact.id}
            else
                raise CustomError.new(get_formatted_errors(contact.errors))
            end
            
        rescue CustomError => ce

            status 400
            ret = {:success => false, :errors => ce.errors}
            
        end

        return ret.to_json

    end

end
