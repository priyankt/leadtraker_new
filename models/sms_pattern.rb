class SmsPattern
	include DataMapper::Resource

	property :id, Serial
	property :source_name, String, :required => true
	property :sms_pattern, String, :length => 640, :required => true
	property :cols, String, :required => true

	property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

    def format_for_app

    	return {
            :id => self.id,
    		:source_name => self.source_name,
    		:sms_pattern => self.sms_pattern,
    		:cols => self.cols
    	}

    end
  
end
