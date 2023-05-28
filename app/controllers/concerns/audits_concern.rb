module AuditsConcern
  extend ActiveSupport::Concern

  included do
    private

    def set_audit_additional_data
      CaseReport.set_additional_data(
        first_name: requester_first_name,
        last_name: requester_last_name,
      )
    end

    def skip_audit?
      skip = request.headers['X-Skip-Audit']
      skip.present? && ActiveModel::Type::Boolean.new.cast(skip)
    end
  end
end