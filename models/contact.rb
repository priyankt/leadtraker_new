class Contact
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
	property :company, String
	property :title, String
	property :address, String
	property :city, String
	property :state, String
	property :zip, Integer

	property :created_at, DateTime, :lazy => true
	property :updated_at, DateTime, :lazy => true
	property :deleted_at, DateTime, :lazy => true

	has n, :phone_numbers
	has n, :email_addresses

	belongs_to :user
  
end
