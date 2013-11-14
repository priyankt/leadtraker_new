class User
	include DataMapper::Resource

    property :id, Serial
    property :fullname, String, :required => true
    property :email, String, :format => :email_address, :required => true, :unique => true
    property :password, BCryptHash, :required => true
    property :phone, String
    property :mobile, String
    property :company, String
    property :address, String
    property :city, String
    property :state, String
    property :zip, String
    property :type , Enum[:agent, :lender], :default => :agent, :required => true
    #property :share_contact, Boolean, :default => true
    #mount_uploader :profile_pic, Uploader
    property :sponsor_id, String
    property :auth_token, APIKey
    property :android_token, String
    property :ios_token, String

    property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

    has n, :lead_types
    has n, :lead_sources
    has n, :expenses
    #has n, :user_affiliates, :child_key => [ :lender_id ]
    #has n, :affiliates, self, :through => :user_affiliates, :via => :agent 

    after :save, :setup_defaults

    def setup_defaults

        # setup default values before save
    	if self.lead_sources.count == 0

            if self.type == :agent
                lead_sources = JSON.parse File.read("public/agent_lead_sources.json")
            else
                lead_sources = JSON.parse File.read("public/lender_lead_sources.json")
            end

            lead_sources.each do |ls|

                source = LeadSource.new(:name => ls["name"], :user_id => self.id)
                if source.valid?
                    source.save
                end

            end

        end

        if self.lead_types.count == 0

            if self.type == :agent
                lead_types = JSON.parse File.read("public/agent_lead_types.json")
            else
                lead_types = JSON.parse File.read("public/lender_lead_types.json")
            end

            lead_types.each do |lt|
                type = LeadType.new(:name => lt["name"], :user_id => self.id)
                if type.valid?
                    type.save
                    lt["leadStages"].each do |ls|
                        stage = LeadStage.new(:name => ls["name"], :lead_type_id => type.id)
                        if stage.valid?
                            stage.save
                        end
                    end
                end
            end

        end
    	
    end

end
