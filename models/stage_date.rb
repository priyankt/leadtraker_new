class StageDate
	include DataMapper::Resource

	property :id, Serial
	property :dttm, DateTime

	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true
	
	belongs_to :lead_user
	belongs_to :lead_stage
  
end
