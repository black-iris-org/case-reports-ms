require "rails_helper"

RSpec.describe AuditMailer, type: :mailer do
  describe "audit_activities" do
    let(:mail) { AuditMailer.audit_activities }

    it "renders the headers" do
      expect(mail.subject).to eq("Audit activities")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
