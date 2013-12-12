class LeadSource
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
  	property :description, String
    
  	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

    belongs_to :user

    def format_for_app

    	return {
    		:id => self.id,
    		:name => self.name,
    		:description => self.description
    	}
    	
    end
  
end
