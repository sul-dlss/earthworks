class LoginController < ApplicationController

  def login
    # devise will handle the redirection to WebAuth and WebAuth will use that referrer
    # to send us back to whence we came, but since the referrer will be our login auth page,
    # we send a parameter so we can take the user back to their starting page
    redirect_to params[:url] || '/'
  end

end
