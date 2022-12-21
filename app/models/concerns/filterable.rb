module Filterable
  extend ActiveSupport::Concern

  class_methods do
    def filter_records(filters)
      build_relations(filters.symbolize_keys).reduce(all) do |base, new_relation|
        base.send(new_relation[:op], new_relation[:value])
      end
    end

    # array of strings of model attributes that support being filtered through a basic where statement
    def filterable_attributes
      []
    end

    def add_filter(filter_name, op = :merge, &block)
      custom_filters[filter_name.to_sym] = { op: op, block: block }
    end

    # private

    def custom_filters
      @custom_filters ||= {}
    end

    def build_relations(filters)
      filters.map { |filter_name, value| get_relation(filter_name, value) }
    end

    def get_relation(filter_name, value)
      if custom_filters.key?(filter_name)
        { op: custom_filters[filter_name][:op], value: custom_filters[filter_name][:block].call(value) }
      elsif filterable_attributes.include?(filter_name)
        { op: :merge, value: where(filter_name => value) }
      else
        raise FilterNotSupported, "Filtering by '#{filter_name}' is not supported."
      end
    end
  end
end

class FilterNotSupported < StandardError; end
