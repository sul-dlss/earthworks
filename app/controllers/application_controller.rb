class ApplicationController < ActionController::Base
  # See config/initializers/bot_challenge_page.rb to control this behavior
  before_action do |controller|
    BotChallengePage::BotChallengePageController.bot_challenge_enforce_filter(controller)
  end

  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  before_action :allow_geoblacklight_params

  layout :determine_layout if respond_to? :layout

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # override devise function for determining where to go after logout
  def after_sign_out_path_for(_resource_or_scope)
    '/Shibboleth.sso/Logout'
  end

  def allow_geoblacklight_params
    # Blacklight::Parameters will pass these to params.permit
    blacklight_config.search_state_fields.append(Settings.GBL_PARAMS)
  end
end
