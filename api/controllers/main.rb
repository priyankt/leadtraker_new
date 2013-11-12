LeadTraker::Api.controllers do

    # Register User
    post '/register' do

        # user = User.new
        # user.fullname = params[:fullname] if params.has_key?("fullname")
        # user.email = params[:email] if params.has_key?("email")
        # user.password = params[:password] if params.has_key?("password")
        # user.phone = params[:phone] if params.has_key?("phone")
        # user.mobile = params[:mobile] if params.has_key?("mobile")
        # user.company = params[:company] if params.has_key?("company")
        # user.address = params[:address] if params.has_key?("address")
        # user.city = params[:city] if params.has_key?("city")
        # user.state = params[:state] if params.has_key?("state")
        # user.zip = params[:zip] if params.has_key?("zip")
        # user.type = params[:type] if params.has_key?("type")
        
        ret = {}
        begin

            if params[:type].blank?
                raise CustomError.new(['Please select if you are an agent or lender'])
            end

            # params["leadSources"] = get_lead_sources(params[:type])
            # params["leadTypes"] = get_lead_types(params[:type])

            user = User.new(params)

            if user.valid?

                User.transaction do
                    begin
                        user.save
                    end
                end

                Resque.enqueue(SendEmail, {
                    :mailer_name => 'user_notifier',
                    :email_type => 'new_user',
                    :user_id => user.id,
                })
                
                status 201
                ret = {:success => 1, :auth_token => user.auth_token}
            else
                raise CustomError.new(get_formatted_errors(user.errors))
            end
            
        rescue CustomError => ce

            status 400
            ret = {:success => 0, :errors => ce.errors}

        end
        
        return ret.to_json

    end

    post '/login' do

        ret = {}
        begin

            email = params[:email] if params.has_key?('email')
            password = params[:password] if params.has_key?('password')
            user = User.first(:email => email)
            if user.present? and user.password == password
                if user.auth_token.blank?
                    user.auth_token = (User.new).auth_token
                    user.save
                end
                ret = {:success => 1, :auth_token => user.auth_token}
            else
                raise CustomError.new(['Invalid user or password. Please try again.'])
            end

            status 200
            
        rescue CustomError => ce

            status 400
            ret = {:success => 0, :errors => ce.errors}

        end
        
        return ret.to_json

    end

    # Reset User Password
    post '/forgot_password' do
        
        email = params[:email] if params.has_key?('email')

        ret = {}
        begin

            if email.blank?
                raise CustomError.new(["Please provide registered email address to send new password."])
            end

            user = User.first(:email => email)
            if user.blank?
               raise CustomError.new(["Email #{email} is not registered. Please provide a registered email address."]) 
            end

            new_passwd = SecureRandom.hex(3)
            user.password = new_passwd
            if user.valid?
                user.save
                Resque.enqueue(SendEmail, {
                    :mailer_name => 'user_notifier',
                    :email_type => 'forgot_password',
                    :user_id => user.id,
                    :new_passwd => new_passwd
                })
                status 200
                ret = {:success => 1}
            else
                raise CustomError.new(get_formatted_errors(user.errors))
            end
            
        rescue CustomError => ce

            status 400
            ret = {:success => 0, :errors => ce.errors}

        end
        
        return ret.to_json

    end

end
