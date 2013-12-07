class EmailAddress
	include DataMapper::Resource

	property :id, Serial
	property :value, String, :required => true, :format => :email_address
	property :type , Enum[:personal, :home, :office, :other], :default => :personal, :required => true

	property :created_at, DateTime, :lazy => true
  	property :updated_at, DateTime, :lazy => true
  	property :deleted_at, ParanoidDateTime, :lazy => true

  	belongs_to :contact
  
end
