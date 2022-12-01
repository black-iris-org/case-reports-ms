module CaseReport::RevisionSavingConcern
  extend ActiveSupport::Concern

  included do
    def create_or_update(**, &block)
      set_instance_to_table
      handle_create_revision
      super
    ensure
      set_instance_to_view
    end

    private

    def set_instance_to_table
      self.class.class_eval { set_to_table }
    end

    def set_instance_to_view
      self.class.class_eval { set_to_view }
    end

    def handle_create_revision
      return if revision.blank? || revision.case_report.present?

      revision.case_report = self
    end
  end

  class_methods do

    private

    def set_to_table
      self.table_name = :case_reports
    end

    def set_to_view
      self.table_name = :case_reports_view
    end
  end
end
