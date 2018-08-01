class ApplicationController < ActionController::Base

  # Adds a few additional behaviors into the application controller
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'earthworks'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # override devise function for determining where to go after logout
  def after_sign_out_path_for(resource_or_scope)
    '/Shibboleth.sso/Logout'
  end
end
