FactoryBot.define do
  factory :report do
    association :reporter, factory: :user
    association :reported_user, factory: :user
    report_type { 'Harassment' }
    description { 'Test description' }
  end
end