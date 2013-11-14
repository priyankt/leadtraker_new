class Note
	include DataMapper::Resource

	property :id, Serial
	property :text, String
	property :shared, Boolean

	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

end
