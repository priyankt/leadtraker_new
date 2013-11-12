class LeadStage
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
  	property :description, String

  	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

    belongs_to :lead_type

end
