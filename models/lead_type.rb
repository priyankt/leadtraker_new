class LeadType
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
  	property :description, String

  	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

    has n, :lead_stages
    belongs_to :user

    # after :save, :assign_stages

    # def assign_stages

    #     # setup default values before save
    # 	if self.leadStages.count == 0
    #         if self.user.type == :agent
    #         	if self.name == "Buyer"
    #         		stages = JSON.parse File.read("public/agent_buyer_stages.json")
    #         	elsif self.name == "Seller"
    #         		stages = JSON.parse File.read("public/agent_seller_stages.json")
    #         	end
    #         else
    #             if self.name == "Purchase"
    #         		stages = JSON.parse File.read("public/lender_purchase_stages.json")
    #         	elsif self.name == "Re-Finance"
    #         		stages = JSON.parse File.read("public/lender_refinance_stages.json")
    #         	end
    #         end

    #         stages.each do |s|
    #             self.leadStages << LeadStage.new(s)
    #         end

    #         self.leadStages.save

    #     end
    	
    # end
  
end
