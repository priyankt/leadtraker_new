class PhoneNumber
	include DataMapper::Resource

	property :id, Serial
	property :value, String, :required => true
	property :type , Enum[:mobile, :home, :office, :other], :default => :mobile, :required => true

	property :created_at, DateTime, :lazy => true
  	property :updated_at, DateTime, :lazy => true
  	property :deleted_at, DateTime, :lazy => true

  	belongs_to :contact
  
end
