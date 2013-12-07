LeadTraker::Api.controllers :affiliate do

    before do

        @user = get_user()
        if @user.blank?
            throw(:halt, [401, "Not Authorized"])
        end

    end

    put '/:id' do

        affiliate = UserAffiliate.first(:id => params[:id])
        
        status = :rejected
        update = Update.new(
            :user_id => affiliate.agent.id, 
            :msg => "Affiliate request rejected by Lender #{affiliate.lender.fullname}", 
            :activity_type => :request_rejected
        )
        if params[:accepted]
            status = :accepted
            update.msg = "Affiliate request accepted by Lender #{affiliate.lender.fullname}"
            update.activity_type = :request_accepted
            if @user.type == :lender
                # remove association with old lender
                active_lender = UserAffiliate.first(:status => :accepted, :agent_id => affiliate.agent.id)
                if active_lender.present?
                    active_lender.update(:status => :rejected)
                end
            end
        end

        affiliate.update(:status => status)
        update.save

        status 200
        return {:success => get_true()}.to_json

    end


end
