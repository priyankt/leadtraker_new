class LeadUser
	include DataMapper::Resource

	property :id, Serial
	property :status, Enum[:active, :inactive, :closed], :default => :active
	property :contact_date, Date
	property :contract_date, Date
	property :closed_date, Date
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
	belongs_to :primary_contact, :model => 'Contact'
	belongs_to :secondary_contact, :model => 'Contact', :required => false

	before :save, :copy_expenses
	after :save, :update_affiliates
	after :save, :add_to_user_updates

	def copy_expenses

		if self.id.blank?
			# copy each expense from settings to lead_expense
			self.user.expenses.each do |e|
  				lead_expense = LeadExpense.new(
  					:name => e.name,
  					:percent => e.percent,
  					:value => e.value,
  					:from => e.from,
  					:to => e.to,
  					:cap => e.cap,
  					:expense_id => e.id

  				)
  				self.lead_expenses << lead_expense
  			end
  		end

  	end

  	def update_affiliates

  		if self.user.type == :agent and self.lead_type.share_leads == true
  			affiliated_lenders = self.user.user_affiliates(:status => :accepted)
  			affiliated_lenders.each do |al|
  				lender = al.lender
          lead_source = lender.lead_sources.first(:name.like => '%Agent Referral%')
          primary_contact = find_or_new(lender, self.primary_contact)
          
          secondary_contact = nil
          if self.secondary_contact.present?
            secondary_contact = find_or_new(lender, self.secondary_contact)
          end

	  			af_lead_user = LeadUser.new(
	  				:user_id => lender.id, 
	  				:lead_id => self.lead_id, 
	  				:primary_contact => primary_contact, 
            :secondary_contact => (secondary_contact.present? ? secondary_contact : nil),
	  				:lead_source_id => (lead_source.present? ? lead_source.id : nil)
	  			)

	  			if af_lead_user.valid?
	  				af_lead_user.save
	  			else
	  				puts af_lead_user.errors.inspect
	  			end

	  		end
	  	end

  	end

    def find_or_new(user, contact)

      user_contact = nil
      
      matching_entity = user.contacts.phone_numbers.first(:value => contact.phone_numbers.map{ |ph| ph.value })
      if matching_entity.blank?
        matching_entity = user.contacts.email_addresses.first(:value => contact.email_addresses.map{ |email| email.value })
      end

      if matching_entity.present?
        user_contact = matching_entity.contact
      end

      # create new contact if contact not already available
      if user_contact.blank?
        user_contact_hash = {
          :name => contact.name,
          :company => contact.company,
          :title => contact.title,
          :address => contact.address,
          :city => contact.city,
          :state => contact.state,
          :zip => contact.zip,
          :email_addresses => contact.email_addresses.map{ |e|
            {
              :type => e.type,
              :value => e.value
            }
          },
          :phone_numbers => contact.phone_numbers.map{ |p|
            {
              :type => p.type,
              :value => p.value
            }
          },
          :user_id => user.id
        }

        user_contact = Contact.new(user_contact_hash)
        
        if user_contact.valid?
          user_contact.save
        else

          raise user_contact.errors.inspect
        end

      end

      return user_contact

    end

  	def add_to_user_updates
  		# Lead type is blank means it is a shared lead  that is being added.
	  	# Add this to user updates
	  	if self.lead_type.blank?
	  		msg = "New shared lead from '#{self.lead.agent.fullname}'"
	  		user_update = Update.new(
	  			:activity_type => :new_shared_lead, 
	  			:msg => msg,
	  			:data => {
	  				:lead_id => self.lead.id, 
	  			},
	  			:user_id => self.user.id
	  		)
	  		if user_update.valid?
	  			user_update.save
	  			# Send notification to user
	  			Resque.enqueue(SendNotification, {
                    :user_ids => [self.user.id],
                    :alert => msg,
                    :type => 'new_shared_lead',
                    :id => self.lead.id,
                })
	  		else
	  			logger.debug user_update.errors.inspect
	  		end
	  	end
  	end

end
