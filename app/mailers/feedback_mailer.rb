class FeedbackMailer < ActionMailer::Base
  def submit_feedback(params, ip)
    if params[:name].present?
      @name = params[:name]
    else
      @name = 'No name given'
    end

    if params[:to].present?
      @email = params[:to]
    else
      @email = 'No email given'
    end

    @message = params[:message]
    @url = params[:url]
    @ip = ip
    @user_agent = params[:user_agent]
    @viewport = params[:viewport]

    mail(to: Settings.EMAIL_TO,
         subject: 'Feedback from EarthWorks',
         from: 'feedback@earthworks.stanford.edu',
         reply_to: Settings.EMAIL_TO)
  end
end
