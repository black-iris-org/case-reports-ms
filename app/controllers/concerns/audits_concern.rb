module AuditsConcern
  extend ActiveSupport::Concern

  included do
    before_action :seed_audited_table
    after_action  :clear_audited_store

    private

    def set_audit_additional_data
      CaseReport.set_additional_data(
        first_name: requester_first_name,
        last_name:  requester_last_name,
        )
    end

    def skip_audit?
      return true if action_name == 'update'

      skip = request.headers['X-Skip-Audit']
      skip.present? && ActiveModel::Type::Boolean.new.cast(skip)
    end

    def seed_audited_table
      ReportAudit.update!(email:requester_email)
    end

    def clear_audited_store
      Audited.store[:requester_email] = nil
    end
  end
end
