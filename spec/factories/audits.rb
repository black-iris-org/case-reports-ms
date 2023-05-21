FactoryBot.define do
  factory :old_audit do
    revision
    user_id { rand(1..2147483647) }
    user_name { Faker::Name.name }
    user_type { :manager }
    action { OldAudit.actions.values.sample }
    action_at { Time.current }
  end
end
