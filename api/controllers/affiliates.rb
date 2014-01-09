LeadTraker::Api.controllers :affiliates do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    get '/' do

        if @user.type == :agent
            affiliates = UserAffiliate.all(:agent_id => @user.id, :order => [:created_at.asc]).map{ |af|
                {
                    :id => af.id,
                    :fullname => af.lender.fullname,
                    :email => af.lender.email,
                    :phone => af.lender.phone,
                    :company => af.lender.company,
                    :status => af.status,
                    :dttm => af.created_at
                }
            }
        else
            affiliates = UserAffiliate.all(:lender_id => @user.id, :order => [:created_at.asc]).map{ |af|
                {
                    :id => af.id,
                    :fullname => af.agent.fullname,
                    :email => af.agent.email,
                    :phone => af.agent.phone,
                    :company => af.agent.company,
                    :status => af.status,
                    :dttm => af.created_at
                }
            }
        end

        status 200

        return affiliates.to_json

    end
end
