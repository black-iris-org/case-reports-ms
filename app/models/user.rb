class User < ApplicationModel
  attribute :id, :integer
  attribute :username, :string
  attribute :type, :string
  attribute :first_name, :string
  attribute :last_name, :string

  def as_audited_model
    {
      user_id: id,
      username: username,
      user_type: type,
    }
  end
end
