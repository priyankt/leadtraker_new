##
# Mailer methods can be defined using the simple format:
#
# email :registration_email do |name, user|
#   from 'admin@site.com'
#   to   user.email
#   subject 'Welcome to the site!'
#   locals  :name => name
#   content_type 'text/html'       # optional, defaults to plain/text
#   via     :sendmail              # optional, to smtp if defined, otherwise sendmail
#   render  'registration_email'
# end
#
# You can set the default delivery settings from your app through:
#
#   set :delivery_method, :smtp => {
#     :address         => 'smtp.yourserver.com',
#     :port            => '25',
#     :user_name       => 'user',
#     :password        => 'pass',
#     :authentication  => :plain, # :plain, :login, :cram_md5, no auth by default
#     :domain          => "localhost.localdomain" # the HELO domain provided by the client to the server
#   }
#
# or sendmail (default):
#
#   set :delivery_method, :sendmail
#
# or for tests:
#
#   set :delivery_method, :test
#
# or storing emails locally:
#
#   set :delivery_method, :file => {
#     :location => "#{Padrino.root}/tmp/emails",
#   }
#
# and then all delivered mail will use these settings unless otherwise specified.
#

LeadTraker::Api.mailer :user_notifier do

	email :forgot_password do |user, new_passwd|
	    from 'admin@leadtraker.com'
	    to user.email
	    subject "New password for your LeadTraker account"
	    content_type 'text/html' # optional, defaults to plain/text
	    via :smtp # optional, to smtp if defined, otherwise sendmail
	    render 'user_notifier/forgot_password', :layout => 'email', :locals => {:user => user, :new_passwd => new_passwd}
  	end

  	email :new_user do |user|
	    from 'admin@leadtraker.com'
	    to user.email
	    bcc 'info@productivitymastery.com'
	    subject "Welcome to LeadTraker!"
	    content_type 'text/html' # optional, defaults to plain/text
	    via :smtp # optional, to smtp if defined, otherwise sendmail
	    render 'user_notifier/new_user', :layout => 'email', :locals => {:user => user}
  	end

  	email :invite_agent do |lender, agent_email|
	    from 'admin@leadtraker.com'
	    to agent_email
	    bcc 'info@productivitymastery.com'
	    subject "Invitation to join LeadTraker app from lender #{lender.fullname}"
	    content_type 'text/html' # optional, defaults to plain/text
	    via :smtp # optional, to smtp if defined, otherwise sendmail
	    render 'user_notifier/invite_agent', :layout => 'email', :locals => {:lender => lender, :agent_email => agent_email}
  	end

  	email :invite_lender do |agent, lender_email|
	    from 'admin@leadtraker.com'
	    to lender_email
	    bcc 'info@productivitymastery.com'
	    subject "Invitation to join LeadTraker app from agent #{agent.fullname}"
	    content_type 'text/html' # optional, defaults to plain/text
	    via :smtp # optional, to smtp if defined, otherwise sendmail
	    render 'user_notifier/invite_lender', :layout => 'email', :locals => {:agent => agent, :lender_email => lender_email}
  	end

  	email :user_update do |user, msg|
	    from 'admin@leadtraker.com'
	    to user.email
	    bcc 'info@productivitymastery.com'
	    subject "LeadTraker - Updates"
	    content_type 'text/html' # optional, defaults to plain/text
	    via :smtp # optional, to smtp if defined, otherwise sendmail
	    render 'user_notifier/user_update', :layout => 'email', :locals => {:user => user, :msg => msg}
  	end

end
