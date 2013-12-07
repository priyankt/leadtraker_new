LeadTraker::Api.controllers :note do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    # Add Note
    post '/' do

        begin
            lead_user = LeadUser.first(:lead_id => params[:lead_id], :user_id => @user.id)
            if lead_user.blank?
                raise CustomError.new(["Requested lead does not exists. Please try again."])
            end

            note = Note.new(params)
            note.lead_id = params[:lead_id]
            note.user_id = @user.id

            if note.valid?
                note.save
                status 200
                ret = {:success => get_true(), :id => note.id, :user_id => note.user.id}
            else
                raise CustomError.new(get_formatted_errors(note.errors))
            end
            
        rescue CustomError => ce
            status 400
            ret = {:success => get_false(), :errors => ce.errors}
        end

        return ret.to_json

    end

    # Edit note
    put '/:id' do
        begin
            note = Note.get(params[:id])
            if note.blank?
                raise CustomError.new(["Invalid note. Please try again."])
            end

            if note.update(params)
                status 200
                ret = {:success => get_true()}
            else
                raise CustomError.new(["Error occured while updating note. Please try again."])
            end
            
        rescue CustomError => ce
            status 400
            ret = {:success => get_false(), :errors => ce.errors}
        end

        return ret.to_json
    end

    # Delete note
    delete '/:id' do
        begin
            note = Note.first(:id => params[:id], :user_id => @user.id)
            if note.blank?
                raise CustomError.new(["Invalid note. Please try again."])
            end

            if note.destroy
                status 200
                ret = {:success => get_true()}
            else
                raise CustomError.new(["Error occured while updating note. Please try again."])
            end
            
        rescue CustomError => ce
            status 400
            ret = {:success => get_false(), :errors => ce.errors}
        end

        return ret.to_json
    end

end
