FactoryBot.define do
  factory :old_case_report do
    transient do
      with_sample_attachment { false }
      with_attachments do
        with_sample_attachment ?
          [{
             filename:     "test-sample",
             checksum:     "XYFa0qq+ose3hxY01oMYbw==",
             byte_size:    30954,
             content_type: "application/pdf"
           }] : []
      end
    end

    incident_number { rand(1..2147483647) }
    incident_id { 1 }
    datacenter_id { 1 }
    datacenter_name { 'test' }
    incident_at { Time.now }
    report_type { :amended }
    revisions_attributes do
      attachment                    = {
        user_id:        1,
        responder_name: 'test',
        name:           'test',
      }

      attachment[:files_attributes] = with_attachments if with_attachments.present?

      [attachment]
    end
  end
end
