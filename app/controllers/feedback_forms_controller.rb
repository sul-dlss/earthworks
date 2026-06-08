class FeedbackFormsController < ApplicationController
  def create
    if request.post?
      if valid?
        FeedbackMailer.submit_feedback(params, request.remote_ip).deliver_now
        flash[:success] = t 'earthworks.feedback_form.success'
      end
      respond_to do |format|
        format.json do
          render json: flash
        end
        format.html do
          redirect_to params[:url]
        end
      end
    end
  end

  protected

  def url_regex
    %r{/.*href=.*|.*url=.*|.*http://.*|.*https://.*/i}
  end

  def valid?
    errors = []

    errors << 'You must pass the reCAPTCHA challenge' if current_user.blank? && !verify_recaptcha(action: 'feedback')

    errors << 'A message is required' if params[:message].nil? || params[:message] == ''
    flash.now[:danger] = errors.join('<br/>') unless errors.empty?
    flash.now[:danger].nil?
  end
end
