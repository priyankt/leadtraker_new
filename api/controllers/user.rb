LeadTraker::Api.controllers :user do

    before do
        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    # Change User Password
    put '/change_password' do
        
        ret = {:success => get_true()}
        begin

            old_passwd = params[:old_password] if params.has_key?("old_password")
            new_passwd = params[:new_password] if params.has_key?("new_password")

            if old_passwd and new_passwd
                # Remember gotchas mentioned on https://groups.google.com/forum/#!topic/datamapper/FbIMuSIx1mA
                if @user.password == old_passwd
                    @user.password = new_passwd
                    if @user.valid?
                        @user.save
                        status 200
                        ret = {:success => get_true()}
                    else
                        raise CustomError.new(get_formatted_errors(@user.errors))
                    end
                else
                    raise CustomError.new(['You have provided an invalid current password. Please try again.'])
                end
            else
                raise CustomError.new(['Please provide new password as well as current password.'])
            end
            
        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}

        end

        ret.to_json

    end

    get '/recent' do

        dttm = params[:dttm]

        if dttm.present?
            user_updates = @user.updates.all(:created_at.gt => dttm, :order => [:created_at.desc])
        else
            user_updates = @user.updates.all(:order => [:created_at.desc])
        end

        ret = user_updates.map{ |u|
            {
                :type => u.activity_type,
                :msg => u.msg,
                :dttm => u.created_at,
                :lead_id => (u.data.present? ? u.data['lead_id'] : nil)
            }
        }
        
        return ret.to_json

    end

    put '/invite' do

        begin
            user_email = params[:sponsor_id]
            if user_email.blank?
                raise CustomError.new(['Please provide email address of user to invite'])
            end

            af_user = User.first(:email => params[:sponsor_id])
            if af_user.present? and @user.type == af_user.type
                raise CustomError.new(["#{@user.type} cannot send affiliate request to another #{af_user.type}"])
            end
            
            if @user.type == :agent
                if af_user.blank?
                    # send email to lender that agent has invited you
                    Resque.enqueue(SendEmail, {
                        :mailer_name => 'user_notifier',
                        :email_type => 'invite_lender',
                        :lender_email => user_email,
                        :agent_id => @user.id
                    })
                    ret = {
                        :success => get_true(), 
                        :affiliate => nil, 
                        :msg => "Invitation email has been sent to email #{params[:sponsor_id]}"
                    }
                else
                    # If lender exists in the system, then check if the agent has already some other active lender
                    active_lender = UserAffiliate.first(:status => :accepted, :agent_id => @user.id)
                    if active_lender.blank? or active_lender.lender_id != af_user.id
                        # create user affiliate record for new lender
                        uaf = UserAffiliate.new(:agent_id => @user.id, :lender_id => af_user.id)
                        if uaf.valid?
                            uaf.save
                            ret = {
                                :success => get_true(), 
                                :affiliate => {
                                    :id => uaf.id,
                                    :fullname => uaf.lender.fullname,
                                    :email => uaf.lender.email,
                                    :phone => uaf.lender.phone,
                                    :company => uaf.lender.company,
                                    :status => uaf.status,
                                    :dttm => uaf.created_at
                                },
                                :msg => "Affiliate request has been sent to Lender #{uaf.lender.fullname}"
                            }
                        else
                            raise CustomError.new(get_formatted_errors(uaf.errors))
                        end
                    end
                end
            else
                # send email to agent that you have been invited by lender
                Resque.enqueue(SendEmail, {
                    :mailer_name => 'user_notifier',
                    :email_type => 'invite_agent',
                    :agent_email => user_email,
                    :lender_id => @user.id
                })

                ret = {
                    :success => get_true(), 
                    :affiliate => nil, 
                    :msg => "Invitation email has been sent to email #{params[:sponsor_id]}"
                }
            end

            status 200
            
        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}

        end

        return ret.to_json

    end

    get '/profile' do

        return {
            :fullname => @user.fullname,
            :phone => @user.phone,
            :company => @user.company,
            :address => @user.address,
            :city => @user.city,
            :state => @user.state,
            :zip => @user.zip
        }.to_json

    end

    put '/profile' do

        if @user.update(params)
            ret = {:success => get_true()}
        else
            ret = {:success => get_false(), :errors => ['Some error occured while updating your profile. Please try again.']}
        end

        return ret.to_json

    end

    # Update gcm/ios token for server notifications
    put '/token' do

        if params[:android_token].present?
            @user.update(:android_token => params[:android_token])
        end

        return {:success => get_true()}.to_json

    end

end
