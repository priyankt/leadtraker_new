class LeadUser
	include DataMapper::Resource

	property :id, Serial
	property :status, Enum[:active, :inactive, :closed], :default => :active
	property :contact_date, DateTime
	property :contract_date, DateTime
	property :closed_date, DateTime
	property :gross, Float
	property :commission, Float

	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

    has n, :lead_expenses

    belongs_to :user
  	belongs_to :lead
  	belongs_to :lead_type
  	belongs_to :lead_source
  
end
