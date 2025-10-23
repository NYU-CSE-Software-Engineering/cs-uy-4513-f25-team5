FactoryBot.define do
  factory :listing do
    title { "MyString" }
    description { "MyText" }
    price { "9.99" }
    city { "MyString" }
    user { nil }
  end
end
