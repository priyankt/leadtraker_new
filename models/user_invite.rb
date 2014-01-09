class UserInvite
	include DataMapper::Resource

	property :id, Serial
	property :invite_email, String, :format => :email_address, :required => true, :unique => true

	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

    belongs_to :user

    after :create, :notify_user_by_email

    def notify_user_by_email
    	
    	if self.user.type == :agent
    		# invite lender
    		Resque.enqueue(SendEmail, {
	            :mailer_name => 'user_notifier',
	            :email_type => 'invite_lender',
	            :lender_email => self.invite_email,
	            :agent_id => self.user.id
        	})
    	else
    		# invite agent
    		Resque.enqueue(SendEmail, {
	            :mailer_name => 'user_notifier',
	            :email_type => 'invite_agent',
	            :agent_email => self.invite_email,
	            :lender_id => self.user.id
        	})
    	end

    end
  
end
