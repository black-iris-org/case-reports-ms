# frozen_string_literal: true

module CsvConcern
  extend ActiveSupport::Concern

  class_methods do
    def to_csv(headers: true, attributes: column_names)
      attributes = attributes.map(&:to_sym)
      CSV.generate(headers: headers) do |csv|
        csv << attributes
        all.each { |audit| csv << attributes.map { |attr| audit.send(attr) } }
      end
    end
  end
end