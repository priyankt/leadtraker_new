class Contact
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true
	property :company, String
	property :title, String
	property :address, String
	property :city, String
	property :state, String
	property :zip, String

	property :created_at, DateTime, :lazy => true
	property :updated_at, DateTime, :lazy => true
	property :deleted_at, ParanoidDateTime, :lazy => true

	has n, :phone_numbers
	has n, :email_addresses

	belongs_to :user

	after :save, :update_affiliates

	def update_affiliates
		
	end

	def format_for_app
		
		return {
            :id => self.id,
            :name => self.name,
            :company => self.company,
            :title => self.title,
            :address => self.address,
            :city => self.city,
            :state => self.state,
            :zip => self.zip,
            :phone_numbers => self.phone_numbers.map{ |p| p.format_for_app },
            :email_addresses => self.email_addresses.map { |e| e.format_for_app }
        }

	end
  
end
