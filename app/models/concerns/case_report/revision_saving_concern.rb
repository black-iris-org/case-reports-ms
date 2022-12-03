module CaseReport::RevisionSavingConcern
  extend ActiveSupport::Concern

  included do
    # Override to write to the table instead of the view
    def create_or_update(**, &block)
      set_instance_to_table
      super
    ensure
      set_instance_to_view
    end

    def update!(attributes)
      if super
        reload
        true
      end

      false
    end

    private

    def set_instance_to_table
      self.class.class_eval { set_to_table }
    end

    def set_instance_to_view
      self.class.class_eval { set_to_view }
    end
  end

  class_methods do
    def create!(attributes)
      super.reload
    end

    private

    def set_to_table
      self.table_name = :case_reports
    end

    def set_to_view
      self.table_name = :case_reports_view
    end
  end
end
