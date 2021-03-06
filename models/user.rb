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
    has n, :updates
    has n, :contacts

    has n, :user_affiliates, :child_key => [ :agent_id ]
    has n, :lenders, self, :through => :user_affiliates, :via => :lender 

    before :create, :generate_sponsor_id
    after :create, :setup_defaults
    
    # Set sponsor id as email id only if type is lender
    def generate_sponsor_id

        if self.type == :lender
            self.sponsor_id = self.email
        else
            self.sponsor_id = nil
        end

    end

    def setup_defaults

        # setup default values before save
    	if self.lead_sources.count == 0

            if self.type == :agent
                lead_sources = JSON.parse File.read("public/agent_lead_sources.json")
            else
                lead_sources = JSON.parse File.read("public/lender_lead_sources.json")
            end

            lead_sources.each do |ls|
                ls["user_id"] = self.id
                source = LeadSource.new(ls)
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
                lt["user_id"] = self.id
                type = LeadType.new(lt)
                if type.valid?
                    type.save
                end
            end

        end

        if self.expenses.count == 0

            if self.type == :agent
                expenses = JSON.parse File.read("public/agent_expense.json")
            else
                expenses = JSON.parse File.read("public/agent_expense.json")
            end
            expenses.each do |e|
                e["user_id"] = self.id
                expense = Expense.new(e)
                if expense.valid?
                    expense.save
                end
            end

        end

        user_invites = UserInvite.all(:invite_email => self.email)
        # check if any pending invites in user_invites
        if user_invites.length > 0
            user_invites.each do |ui|
                if self.type == :lender
                    UserAffiliate.create(:agent_id => ui.user.id, :lender_id => self.id)
                else
                    UserAffiliate.create(:agent_id => self.id, :lender_id => ui.user.id)
                end
            end
        end
    	
    end

end
