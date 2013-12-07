class Appointment
	include DataMapper::Resource

	property :id, Serial
	property :text, String
	property :dttm, DateTime, :required => true
	property :shared, Boolean, :default => true

	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

    belongs_to :lead
    belongs_to :user

    after :save, :update_affiliates

    def update_affiliates

    	LeadUser.all(:lead_id => self.lead_id).each do |alu|
    		if self.shared and alu.user_id != self.user_id
    			user_update = Update.new(
    				:activity_type => :new_shared_task,
    				:msg => "New task added for lead '#{alu.primary_contact.name}'",
    				:data => {:lead_id => self.lead_id},
    				:user_id => alu.user_id
    			)
    			if user_update.valid?
    				user_update.save
    			else
    				puts user_update.errors.inspect
    			end
    		end
    	end

    end
  
end
