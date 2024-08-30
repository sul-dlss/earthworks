# Override allows for:
# 1. moving of start button to end of selected items
# 2. constraints-label not being visually-hidden
# 3. To override default start button
class ConstraintsComponent < Blacklight::ConstraintsComponent
  def initialize(**args)
    super
    @start_over_component = StartOverButtonComponent
  end
end
