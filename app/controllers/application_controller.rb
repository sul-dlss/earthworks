class ApplicationController < ActionController::Base

  include Squash::Ruby::ControllerMethods
  enable_squash_client

  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  layout 'earthworks'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # to use the login/logout features, add a :referrer parameter to your URL
  def devise_referrer_path
    params[:referrer] || root_path
  end
  
  # override devise function for determining where to go after logout
  def after_sign_out_path_for(resource_or_scope)
    devise_referrer_path
  end
end
