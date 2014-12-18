class LoginController < ApplicationController
  def login
    redirect_to devise_referrer_path
  end
end
