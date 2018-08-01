class LoginController < ApplicationController
  def login
    redirect_to params[:referrer] || root_path
  end
end
