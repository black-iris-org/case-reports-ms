FactoryBot.define do
  factory :case_report do
    incident_number { rand(1..2147483647) }
  end
end
