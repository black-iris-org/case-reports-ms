FactoryBot.define do
  factory :case_report do
    transient do
      with_sample_attachment { false }
      with_attachments { []}
      sample_attachment {
          {
            filename:     "test-sample",
            checksum:     "XYFa0qq+ose3hxY01oMYbw==",
            byte_size:    30954,
            content_type: "application/pdf"
          }
      }
    end

    incident_number { rand(1..2147483647) }
    incident_id { 1 }
    datacenter_id { 1 }
    datacenter_name { 'test' }
    incident_at { Time.now }
    report_type { :amended }
    user_id { 1 }
    responder_name { 'test' }
    name { 'test' }

    files_attributes {
      list = []
      list << sample_attachment if with_sample_attachment
      list + with_attachments
    }
  end
end
