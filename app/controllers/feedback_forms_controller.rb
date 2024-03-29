class FeedbackFormsController < ApplicationController
  def new; end

  def create
    if request.post?
      if validate
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

  def validate
    errors = []

    errors << 'You did not pass the reCaptcha challenge' if current_user.blank? && !verify_recaptcha

    errors << 'A message is required' if params[:message].nil? || params[:message] == ''
    if params[:email_address] && params[:email_address] != ''
      # rubocop:disable Layout/LineLength
      errors << 'You have filled in a field that makes you appear as a spammer.  Please follow the directions for the individual form fields.'
      # rubocop:enable Layout/LineLength
    end
    if params[:message]&.match?(url_regex)
      # rubocop:disable Layout/LineLength
      errors << 'Your message appears to be spam, and has not been sent. Please try sending your message again without any links in the comments.'
      # rubocop:enable Layout/LineLength
    end
    if params[:user_agent] =~ url_regex ||
       params[:viewport] =~ url_regex
      errors << 'Your message appears to be spam, and has not been sent.'
    end
    flash[:danger] = errors.join('<br/>') unless errors.empty?
    flash[:danger].nil?
  end
end
