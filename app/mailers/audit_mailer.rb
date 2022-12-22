class AuditMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.audit_mailer.audit_activities.subject
  #
  def audit_activities
    @user_email = params[:user_email]
    attachments[params[:file_name]] = params[:file_content]
    mail(to: @user_email)
  end
end
