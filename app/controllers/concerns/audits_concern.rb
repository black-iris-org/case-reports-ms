module AuditsConcern
  extend ActiveSupport::Concern

  included do
    private

    def add_audit_record(action = action_name)
      Audit.create!(
        revision_id: @revision_id,
        user_id: requester_id,
        user_name: requester_name,
        user_type: requester_role,
        action: action
      )
    rescue StandardError => exception
      warn "Something went wrong while saving the audit record"
      warn "Action name: #{action_name}"
      warn "Exception message: #{exception.message}"
    end

    def skip_audit?
      skip = request.headers['X-Skip-Audit']
      skip.present? && ActiveModel::Type::Boolean.new.cast(skip)
    end
  end
end