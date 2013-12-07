LeadTraker::Api.controllers :stage do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    put '/' do

        begin

            lead_user = LeadUser.first(:lead_id => params[:lead_id], :user_id => @user.id)
            if lead_user.blank?
                raise CustomError.new(['Invalid lead. Please try again.'])
            end

            lead_user.current_stage = StageDate.new(:dttm => DateTime.now, :lead_stage_id => params[:stage_id], :lead_user_id => lead_user.id)
            if lead_user.valid?
                lead_user.save
                status 200
                ret = {:success => get_true(), :id => lead_user.current_stage.id}
            else
                raise CustomError.new(get_formatted_errors(lead_user.current_stage.errors))
            end

        rescue CustomError => ce
            status 400
            ret = {:success => get_false(), :errors => ce.errors}
        end

        return ret.to_json

    end

end
