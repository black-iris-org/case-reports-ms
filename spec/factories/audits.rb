FactoryBot.define do
  factory :audit do
    revision
    user_id { rand(1..2147483647) }
    user_name { Faker::Name.name }
    email { Faker::Name.email }
    user_type { :manager }
    action { Audit.actions.values.sample }
    action_at { Time.current }
  end
end
