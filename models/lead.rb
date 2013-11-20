class Lead
	include DataMapper::Resource

	property :id, Serial
	property :prop_address, String
	property :prop_city, String
	property :prop_state, String
	property :prop_zip, String
	property :reference, String

	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

	has n, :lead_users
  	has n, :users, :through => :lead_users

  	belongs_to :agent, :model => 'User'

end
