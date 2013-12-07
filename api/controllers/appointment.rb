LeadTraker::Api.controllers :appointment do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    # Add Appointment
    post '/' do

        begin
            lead_user = LeadUser.first(:lead_id => params[:lead_id], :user_id => @user.id)
            if lead_user.blank?
                raise CustomError.new(["Requested lead does not exists. Please try again."])
            end

            appointment = Appointment.new(params)
            appointment.lead_id = params[:lead_id]
            appointment.user_id = @user.id

            if appointment.valid?
                appointment.save
                status 200
                ret = {:success => get_true(), :id => appointment.id, :user_id => appointment.user.id}
            else
                raise CustomError.new(get_formatted_errors(appointment.errors))
            end
            
        rescue CustomError => ce
            status 400
            ret = {:success => get_false(), :errors => ce.errors}
        end

        return ret.to_json

    end

    put '/:id' do
        begin

            appointment = Appointment.first(:id => params[:id], :user_id => @user.id)
            if appointment.blank?
                raise CustomError.new(["Invalid appointment. Please try again."])
            end

            if appointment.update(params)
                status 200
                ret = {:success => true, :id => appointment.id, :user_id => appointment.user.id}
            else
                raise CustomError.new(["Error updating appointment. Please try again."])
            end
            
        rescue CustomError => ce
            status 400
            ret = {:success => get_false(), :errors => ce.errors}
        end

        return ret.to_json
    end

    delete '/:id' do
        begin

            appointment = Appointment.first(:id => params[:id], :user_id => @user.id)
            if appointment.blank?
                raise CustomError.new(["Invalid appointment. Please try again."])
            end

            if appointment.destroy
                status 200
                ret = {:success => get_true()}
            else
                raise CustomError.new(["Error updating appointment. Please try again."])
            end
            
        rescue CustomError => ce
            status 400
            ret = {:success => get_false(), :errors => ce.errors}
        end

        return ret.to_json
    end

end
