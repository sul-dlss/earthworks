FactoryBot.define do
  factory :layer, class: GeoMonitor::Layer do
    sequence(:slug) { |n| "institution-#{n}" }
  end
end
