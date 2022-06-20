require 'rails_helper'

describe FeedbackFormHelper do
  describe '#show_feedback_form?' do
    it 'returns true when not under the FeedbackFormsController' do
      expect(helper.show_feedback_form?).to be_truthy
    end
  end
end
