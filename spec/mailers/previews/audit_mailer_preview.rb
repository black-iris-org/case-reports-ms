# Preview all emails at http://localhost:3000/rails/mailers/audit_mailer
class AuditMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/audit_mailer/audit_activities
  def audit_activities
    AuditMailer.audit_activities
  end

end
