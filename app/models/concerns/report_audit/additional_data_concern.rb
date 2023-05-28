# frozen_string_literal: true

module ReportAudit::AdditionalDataConcern
  extend ActiveSupport::Concern

  class_methods do
    def define_additional_attribute(name)
      define_method name do
        additional_data&.[](name.to_s)
      end

      define_method "#{name}=" do |value|
        additional_data&.[]=(name.to_s, value)
      end
    end
  end
end