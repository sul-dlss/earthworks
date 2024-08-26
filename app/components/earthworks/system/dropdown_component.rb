# frozen_string_literal: true

module Earthworks
  module System
    class DropdownComponent < Blacklight::System::DropdownComponent
     def before_render
        with_button(label: button_label, classes: %w[btn btn-outline-primary dropdown-toggle])
        super
      end
    end
  end
end
