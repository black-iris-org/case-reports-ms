# frozen_string_literal: true
require 'pagy'
require 'pagy/extras/array'

module PaginationConcern
  extend ActiveSupport::Concern

  included do
    include ::Pagy::Backend

    def paginate(relation)
      if relation.is_a?(Array)
        @pagy, result = pagy_array(relation, pagination_params)
      else
        @pagy, result = pagy(relation, pagination_params)
      end
      result
    end

    def pagination_params
      params[:paginate]&.permit(:page, :size, :items, :count).to_h.symbolize_keys || {}
    end

    def pagination_status
      @pagy.as_json.except("vars", "params")
    end

    def pagination_meta
      { pagination: pagination_status }
    end
  end
end
