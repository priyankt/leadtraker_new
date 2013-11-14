LeadTraker::Api.controllers :user do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    # Change User Password
    post '/change_password' do
        
        ret = {:success => 0}
        begin

            old_passwd = params[:old_passwd] if params.has_key?("old_passwd")
            new_passwd = params[:new_passwd] if params.has_key?("new_passwd")

            if old_passwd and new_passwd
                # Remember gotchas mentioned on https://groups.google.com/forum/#!topic/datamapper/FbIMuSIx1mA
                if @user.password == old_passwd
                    @user.password = new_passwd
                    if @user.valid?
                        @user.save
                        status 200
                        ret = {:success => 1}
                    else
                        status 400
                        ret = {:success => 0, :errors => get_formatted_errors(@user.errors)}
                    end
                else
                    raise CustomError.new(['You have provided an invalid current password. Please try again.'])
                end
            else
                raise CustomError.new(['Please provide new password as well as current password.'])
            end
            
        rescue CustomError => ce

            status 400
            ret = {:success => false, :errors => ce.errors}

        end

        ret.to_json

    end

    get '/setup' do

        ret = get_setup_data(@user)
        status 200

        return ret.to_json

    end

end
