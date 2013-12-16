class Update
	include DataMapper::Resource

	property :id, Serial
	property :activity_type, Enum[:new_shared_lead, :new_shared_note, :new_shared_task, :request_received, :request_accepted, :request_rejected], :default => :new_shared_lead
	property :msg, String, :required => true
	property :data, Json # all data required by the mobile & web apps
	
	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

    belongs_to :user

    after :save, :notify_users

    def notify_users

    	Resque.enqueue(SendNotification, {
            :ids => [self.user.id], 
            :message => self.msg
        })

    	Resque.enqueue(SendEmail, {
            :mailer_name => 'user_notifier',
            :email_type => 'user_update',
            :user_id => self.user.id,
            :msg => self.msg
        })
        
    end
  
end
