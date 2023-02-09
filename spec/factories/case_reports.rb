FactoryBot.define do
  factory :case_report do
    incident_number { rand(1..2147483647) }
    incident_id { 1 }
    datacenter_id { 1 }
    datacenter_name { 'test' }
    incident_at { Time.now }
    report_type { :amended }
    revisions_attributes {
      [{ user_id: 1,
         responder_name: 'test',
         name: 'test' }
      ] }
  end
end
