FactoryBot.define do
  factory :audit do
    revision
    user_id { rand(1..2147483647) }
    user_name { Faker::Name.name }
    user_type { :manager }
    action { Audit.actions.values.sample }
    created_at { Time.current }
    updated_at { Time.current }
  end
end
