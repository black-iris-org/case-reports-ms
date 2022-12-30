# frozen_string_literal: true

module Revision::FilesConcern
  extend ActiveSupport::Concern
  include Filterable

  included do
    has_many_attached :files

    def files_attributes=(value)
      value.each { |item| files_blobs << ActiveStorage::Blob.create(item) }
    end

    def direct_upload_urls
      files.map { |file| file&.service&.send(:object_for, file&.key)&.presigned_url(:put) }
    end
  end
end
