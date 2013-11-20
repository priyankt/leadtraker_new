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
  	belongs_to :lead_type, :required => false
  	belongs_to :lead_source, :required => false
  	belongs_to :current_stage, :model => 'StageDate', :required => false
  	# which agent gave this lead
  	belongs_to :agent, :model => 'User', :required => false

  	belongs_to :primary_contact, :model => 'Contact'

  	after :save, :update_affiliates

  	def update_affiliates

  		if self.user.type == :agent
  			self.user.affiliates.each do |af|
  				lead_source = af.lead_sources.first('name.like' => '%Agent Referral%')
	  			primary_contact = af.contacts.phone_numbers.first(:value => self.primary_contact.phone_numbers.map{ |ph| ph.value })
	  			if primary_contact.blank?
	  				primary_contact = af.contacts.email_addresses.first(:value => self.primary_contact.email_addresses.map{ |email| email.value })
	  			end
	  			# create new contact if contact not already available
	  			if primary_contact.blank?
	  				#primary_contact = Contact.new(self.primary_contact.attributes.merge(:id => nil))
	  				primary_contact.deep_clone(:phone_numbers, :email_addresses)
	  			end

	  			af_lead_user = LeadUser.new(
	  				:user_id => af.id, 
	  				:lead_id => self.lead_id, 
	  				:primary_contact => primary_contact, 
	  				:lead_source_id => (lead_source.present? ? lead_source.id : nil), 
	  				:agent_id => self.user.id
	  			)

	  			if af_lead_user.valid?
	  				af_lead_user.save
	  			end
	  		end
	  	end

	  	# Lead type is blank means it is a shared lead  that is being added.
	  	# Add this to user updates
	  	if self.lead_type.blank?
	  		user_update = Update.new(
	  			:activity_type => :new_shared_lead, 
	  			:msg => "New shared lead from #{self.lead.agent.name}",
	  			:data => {
	  				:lead_id => self.lead.id, 
	  			},
	  			:user_id => self.user.id
	  		)
	  		if user_update.valid?
	  			user_update.save
	  		else
	  			puts user_update.errors.inspect
	  		end
	  	end

  	end

end
