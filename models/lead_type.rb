class LeadType
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
  	property :description, String
    property :share_leads, Boolean, :default => true

  	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

    has n, :lead_stages
    belongs_to :user

    def format_for_app

    	return {
    		:id => self.id,
    		:name => self.name,
    		:description => self.description,
            :share_leads => self.share_leads,
    		:lead_stages => self.lead_stages.map{ |ls|
    			ls.format_for_app
    		}
    	}

    end
  
end
