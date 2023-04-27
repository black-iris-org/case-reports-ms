require "rails_helper"

RSpec.describe AuditMailer, type: :mailer do
  describe "audit_activities" do
    let(:mail) { AuditMailer.with(user_email:'test@gmail.com', file_content: 'test', file_name: 'test' ).audit_activities }

    it "renders the headers" do
      expect(mail.subject).to eq("Audit activities")
      expect(mail.to).to eq(["test@gmail.com"])
      expect(mail.from).to eq(["info@trekmedics.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("test")
    end
  end

end
