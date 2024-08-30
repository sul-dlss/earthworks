class AlertComponent < ViewComponent::Base
  attr_reader :title, :body, :type, :icon

  def initialize(body:, type:, title: nil)
    super
    @title = title
    @body = body
    @type = type
    @icon = match_icon
  end

  def match_icon
    icon_mapping = { 'info' => 'bi-info-circle-fill', 'warning' => 'bi-exclamation-triangle-fill',
                     'danger' => 'bi-exclamation-triangle-fill', 'sucess' => 'bi-check-circle-fill',
                     'note' => 'bi-exclamation-circle-fill' }
    icon_mapping[type]
  end
end
