LeadTraker::Api.controllers :expense do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    # Add lead_expense
    # post '/' do

    #     begin
    #         lead_user = LeadUser.first(:lead_id => params[:lead_id], :user_id => @user.id)
    #         if lead_user.blank?
    #             raise CustomError.new(["Requested lead does not exists. Please try again."])
    #         end

    #         params.delete(:lead_id)
    #         lead_expense = LeadExpense.new(params)
    #         lead_expense.lead_user_id = lead_user.id
            
    #         if lead_expense.valid?
    #             lead_expense.save
    #             status 200
    #             ret = {:success => true, :id => lead_expense.id}
    #         else
    #             raise CustomError.new(get_formatted_errors(lead_expense.errors))
    #         end
            
    #     rescue CustomError => ce
    #         status 400
    #         ret = {:success => get_false(), :errors => ce.errors}
    #     end

    #     return ret.to_json

    # end

    # Update lead_expense
    put '/' do
        
        begin
            
            expenses = JSON.parse params[:expenses] if params.has_key?('expenses')
            lead_user = LeadUser.first(:lead_id => params[:lead_id], :user_id => @user.id)

            LeadExpense.transaction do
                begin
                    expenses.each do |e|
                        if e['id'] != 0
                            lead_expense = LeadExpense.get(e['id'])
                            if not lead_expense.update(e)
                                raise CustomError.new(['Error occured while updating expense. Please try again.'])
                            end
                        else
                            e.delete('id')
                            lead_expense = LeadExpense.new(e)
                            lead_expense.lead_user_id = lead_user.id
                            if lead_expense.valid?
                                lead_expense.save
                            else
                                raise CustomError.new(get_formatted_errors(lead_expense.errors))
                            end
                        end
                    end
                end
            end

            status 200
            ret = {:success => get_true()}
            
        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}

        end

        return ret.to_json

    end

    # Delete lead_expense
    # delete '/:id' do

    #     begin
            
    #         lead_expense = LeadExpense.first(:id => params[:id])
    #         if lead_expense.blank?
    #             raise CustomError.new(["Invalid expense. Please try again."])
    #         end

    #         if lead_expense.destroy
    #             status 200
    #             ret = {:success => get_true()}
    #         else
    #             raise CustomError.new(get_formatted_errors(lead_expense.errors))
    #         end
            
    #     rescue CustomError => ce
    #         status 400
    #         ret = {:success => get_false(), :errors => ce.errors}
    #     end

    #     return ret.to_json

    # end

end
