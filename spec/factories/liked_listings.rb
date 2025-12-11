FactoryBot.define do
  factory :liked_listing do
    association :user
    association :listing
  end
end

