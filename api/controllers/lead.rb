LeadTraker::Api.controllers :lead do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    # get lead details
    get '/:lead_id' do

        begin
            ret = {}
            lead_user = LeadUser.first(:lead_id => params[:lead_id], :user_id => @user.id)
            if lead_user.blank?
                raise CustomError.new(["Requested lead does not exists. Please try again."])
            end

            info = {}
            info[:lead_type] = (lead_user.lead_type.present? ? {:id => lead_user.lead_type.id, :name => lead_user.lead_type.name} : nil)
            info[:lead_source] = {:id => lead_user.lead_source.id, :name => lead_user.lead_source.name}
            info[:prop_address] = lead_user.lead.prop_address
            info[:prop_city] = lead_user.lead.prop_city
            info[:prop_state] = lead_user.lead.prop_state
            info[:prop_zip] = lead_user.lead.prop_zip
            info[:reference] = lead_user.lead.reference
            info[:agent_name] = lead_user.lead.agent.fullname
            info[:status] = lead_user.status
            info[:current_stage_id] = (lead_user.current_stage.present? ? lead_user.current_stage.lead_stage.id : nil)
            info[:primary_contact] = lead_user.primary_contact.format_for_app
            if lead_user.secondary_contact.present?
                info[:secondary_contact] = lead_user.secondary_contact.format_for_app
            else
                info[:secondary_contact] = nil
            end
            ret[:info] = info

            financial = {}
            financial[:contact_date] = lead_user.contact_date
            financial[:contract_date] = lead_user.contract_date
            financial[:closed_date] = lead_user.closed_date
            financial[:gross] = lead_user.gross
            financial[:commission] = lead_user.commission

            net_income = 0
            if lead_user.gross.present? and lead_user.commission.present?
                net_income = lead_user.gross * lead_user.commission/100
            end

            net_commission = net_income
            financial[:expenses] = lead_user.lead_expenses.map{ |e|

                if net_income.present?
                    if e.value.present?
                        net_income -= e.value
                    elsif e.percent
                        net_income -= e.percent / 100 * net_commission
                    end
                end

                {
                    :id => e.id,
                    :name => e.name,
                    :percent => e.percent,
                    :value => e.value,
                    :from => e.from,
                    :to => e.to,
                    :cap => e.cap
                }
            }
            financial[:net_income] = net_income

            ret[:financial] = financial

            ret[:notes] = lead_user.lead.notes.all(:conditions => ["shared = ? OR user_id = ?", true, @user.id], :order => [:updated_at.desc]).map{ |n|
                {
                    :id => n.id,
                    :text => n.text,
                    :shared => (n.shared ? 1 : 0),
                    :user => n.user.fullname,
                    :user_id => n.user.id,
                    :updated_at => n.updated_at
                }
            }

            ret[:tasks] = lead_user.lead.appointments.all(:conditions => ["shared = ? OR user_id = ?", true, @user.id]).map{ |a|
                {
                    :id => a.id,
                    :text => a.text,
                    :shared => (a.shared ? 1 : 0),
                    :dttm => a.dttm,
                    :user => a.user.fullname,
                    :user_id => a.user.id,
                    :updated_at => a.updated_at
                }
            }

            if lead_user.lead_type.present?
                ret[:stages] = lead_user.lead_type.lead_stages.map{ |s|
                    stage_date = StageDate.first(:lead_stage_id => s.id, :lead_user_id => lead_user.id)
                    {
                        :id => s.id,
                        :name => s.name,
                        :dttm => (stage_date.present? ? stage_date.dttm : nil)
                    }
                }
            else
                ret[:stages] = []
            end

            
        rescue CustomError => ce

            status 400
            ret = {:success => false, :errors => ce.errors}

        end

        return ret.to_json

    end

    # Add new lead
    post '/' do

        begin
            lead = Lead.new
            lead.prop_address = params[:address] if params.has_key?('address')
            lead.prop_city = params[:city] if params.has_key?('city')
            lead.prop_state = params[:state] if params.has_key?('state')
            lead.prop_zip = params[:zip] if params.has_key?('zip')
            lead.reference = params[:reference] if params.has_key?('reference')

            lead_user = LeadUser.new(
                :lead_type_id => params[:lead_type_id], 
                :lead_source_id => params[:lead_source_id], 
                :user_id => @user.id,
                :primary_contact_id => params[:primary_contact_id],
                :secondary_contact_id  => (params[:secondary_contact_id].present? and params[:secondary_contact_id].to_i > 0 ? params[:secondary_contact_id] : nil)
            )

            if params.has_key?('contacted') and params[:contacted]
                lead_user.contact_date = DateTime.now 
            end

            lead.agent = @user
            lead.lead_users << lead_user

            if lead.valid?

                Lead.transaction do
                    begin
                        lead.save
                    end
                end

                status 200
                ret = {:success => get_true(), :id => lead.id}
                
            end

        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}

        end

        return ret.to_json

    end

    # Edit lead id
    put '/:lead_id' do

        begin
            
            lead = Lead.get(params[:lead_id])
            lead_user = LeadUser.first(:lead_id => params[:lead_id], :user_id => @user.id)

            if lead.blank? or lead_user.blank?
                raise CustomError.new(['Invalid lead. Please try again.'])
            end

            Lead.transaction do
                begin
                    lead_hash = {}
                    lead_hash[:prop_address] = params[:address] if params[:address].present?
                    lead_hash[:prop_city] = params[:city] if params[:city].present?
                    lead_hash[:prop_state] = params[:state] if params[:state].present?
                    lead_hash[:prop_zip] = params[:zip] if params[:zip].present?
                    lead_hash[:reference] = params[:reference] if params[:reference].present?
                    lead.update(lead_hash)

                    lead_user_hash = {}
                    lead_user_hash[:primary_contact_id] = params[:primary_contact_id] if params[:primary_contact_id].present? and params[:primary_contact_id].to_i != 0
                    lead_user_hash[:secondary_contact_id] = params[:secondary_contact_id] if params[:secondary_contact_id].present? and params[:secondary_contact_id].to_i != 0
                    lead_user_hash[:lead_source_id] = params[:lead_source_id] if params[:lead_source_id].present?
                    lead_user.update(lead_user_hash)
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

    put '/:lead_id/financial' do

        puts params.inspect
        begin

            lead = Lead.get(params[:lead_id])
            lead_user = LeadUser.first(:lead_id => params[:lead_id], :user_id => @user.id)

            if lead.blank? or lead_user.blank?
                raise CustomError.new(['Invalid lead. Please try again.'])
            end

            lead_user_hash = {}
            lead_user_hash[:gross] = params[:gross] if params[:gross].present?
            lead_user_hash[:commission] = params[:commission] if params[:commission].present?
            lead_user_hash[:contract_date] = params[:contract_date] if params[:contract_date].present?
            lead_user_hash[:closed_date] = params[:closed_date] if params[:closed_date].present?
            lead_user.update(lead_user_hash)

            status 200
            ret = {:success => get_true()}

        rescue CustomError => ce

            status 400
            ret = {:success => get_false(), :errors => ce.errors}

        end

        return ret.to_json

    end

end
