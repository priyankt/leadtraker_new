class UserAffiliate
	include DataMapper::Resource

	property :id, Serial
	property :status, Enum[:pending, :accepted, :rejected], :default => :pending, :required => true

  	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

	belongs_to :lender, 'User', :key => true
	belongs_to :agent, 'User', :key => true

	# after :save, :add_to_user_update
	
	# def add_to_user_update
	
	# 	user_update = Update.new(
	# 		:activity_type => :request_received, 
	# 		:msg => "Affiliate request from #{self.agent.fullname}", 
	# 		:data => {:id => self.id}
	# 		:user => (self.lender.updated_at > self.agent.updated_at)
	# 	)
		
	# 	if user_update.vaild?
	# 		user_update.save
	# 	else
	# 		logger.debug user.update.errors.inspect
	# 	end

	# end

end
