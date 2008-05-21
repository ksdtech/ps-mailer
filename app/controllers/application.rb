# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :authenticate
  
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      # if username == APP_CONFIG[:admin_user] && password == APP_CONFIG[:admin_password]
      u = LDAPUser.authenticate(LDAP_CONFIG, username, password)
      if u
        # session[:user] = u.uid
        # session[:full_name] = u.cn
        # session[:admin] = true
        return true
      end
      return false
    end
  end
end
