FactoryBot.define do
  factory :conversation do
    association :participant_one, factory: :user
    association :participant_two, factory: :user
  end
end