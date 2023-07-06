# frozen_string_literal: true

class ApplicationModel
  include ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  include ActiveModel::Type
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment
  extend ActiveModel::Naming
end
