LeadTraker::Api.controllers :setup do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    get '/' do

        logger.debug params.inspect
        ret = {}

        condt = {}
        if params[:updated_at].present?
            condt = {:updated_at.gt => params[:updated_at]}
        end
        logger.debug condt.inspect

        ret[:lead_sources] = @user.lead_sources.all(condt).map { |ls| ls.format_for_app }
        ret[:lead_types] = @user.lead_types.all(condt).map { |lt| lt.format_for_app }
        ret[:expenses] = @user.expenses.all(condt).map { |e| e.format_for_app }
        ret[:contacts] = @user.contacts.all(condt).map { |c| c.format_for_app }
        ret[:sms_patterns] = SmsPattern.all(condt).map { |sp| sp.format_for_app }

        status 200

        return ret.to_json

    end

    post '/lead_source' do

        begin

            lead_source = LeadSource.new(params)
            lead_source.user_id = @user.id
            if lead_source.valid?
                lead_source.save
                status 201
                ret = lead_source.format_for_app
            else
                raise CustomError.new(get_formatted_errors(lead_source.errors))
            end

        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}
            
        end

        return ret.to_json

    end

    put '/lead_source/:id' do
        logger.debug params.inspect

        begin

            if params[:id].blank?
                raise "Invalid lead source. Please try again"
            end
            lead_source = LeadSource.get(params[:id])
            lead_source.update(:name => params[:name])
            status 200
            ret = lead_source.format_for_app

        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}
            
        end

        return ret.to_json

    end

    post '/lead_type' do

        begin
            
            lead_type = LeadType.new(:name => params[:name], :share_leads => params[:share_leads], :lead_stages => JSON.parse(params[:lead_stages]), :user_id => @user.id )
            if lead_type.valid?
                lead_type.save
                status 201
                ret = lead_type.format_for_app
            else
                raise CustomError.new(get_formatted_errors(lead_type.errors))
            end

        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}
            
        end

        return ret.to_json

    end

    put '/lead_type/:id' do

        begin
            
            lead_type = @user.lead_types.get(params[:id])
            if lead_type.blank?
                raise CustomError.new(['Invalid lead type provided.'])
            end

            lead_type.update(:name => params[:name], :share_leads => params[:share_leads])

            lead_stages = JSON.parse(params[:lead_stages])
            lead_stages.each do |ls|
                if ls['id'] > 0
                    stage = LeadStage.get(ls['id'])
                    stage.update(:name => ls['name'])
                else
                    stage = LeadStage.new(:name => ls['name'])
                    stage.lead_type_id = lead_type.id
                    if stage.valid?
                        stage.save
                    else
                        raise CustomError.new(get_formatted_errors(stage.errors))
                    end
                end
            end

            status 200
            ret = lead_type.format_for_app

        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}
            
        end

        return ret.to_json

    end

    post '/expense' do
        logger.debug params.inspect

        begin
            
            expense = Expense.new(
                :name => params['name'],
                :percent => params['percent'].to_f,
                :value => params['value'].to_f,
                :cap => params['cap'].to_f,
                :from => params['from'],
                :to => params['to'],
                :user_id => @user.id
            )
            if expense.valid?
                expense.save
                status 201
                ret = expense.format_for_app
            else
                raise CustomError.new(get_formatted_errors(expense.errors))
            end

        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}
            
        end

        return ret.to_json

    end

    put '/expense/:id' do

        logger.debug params.inspect
        begin
            
            expense = Expense.get(params[:id])
            expense.update(
                :name => params['name'],
                :percent => params['percent'].to_f,
                :value => params['value'].to_f,
                :cap => params['cap'].to_f,
                :from => params['from'],
                :to => params['to'],
            )
            status 200
            ret = expense.format_for_app

        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}
            
        end

        return ret.to_json

    end

end
