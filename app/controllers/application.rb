# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '0be3db1978570ed5818f64a8e6f082a2'
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_assetmgr_session_id'
  before_filter :authenticate
  
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      if username == APP_CONFIG[:admin_user] && password == APP_CONFIG[:admin_password]
        session[:user] = username
        session[:admin] = true
        session[:full_name] = username
        return true
      end
      return false
    end
  end
end
