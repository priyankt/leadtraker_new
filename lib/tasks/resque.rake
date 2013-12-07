require 'resque/tasks'

namespace :resque do
  desc "Load the Application Development for Resque"
  task :setup => :environment do
    ENV['QUEUES'] = 'leadtraker_send_email,leadtraker_send_notification'
    # ENV['VERBOSE']  = '1' # Verbose Logging
    # ENV['VVERBOSE'] = '1' # Very Verbose Logging
  end
end
