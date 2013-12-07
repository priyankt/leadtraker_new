class LeadExpense
	include DataMapper::Resource

	property :id, Serial
	property :name, String
	# percentage of gross
	property :percent, Float
	# flat value irrespective of gross
	property :value, Float
	# date range
	property :from, Date
	property :to, Date
	# cap for the date range
	property :cap, Float

    property :created_at, DateTime, :lazy => true
    property :updated_at, DateTime, :lazy => true
    property :deleted_at, ParanoidDateTime, :lazy => :true

    belongs_to :expense, :required => false
    belongs_to :lead_user
  
end
