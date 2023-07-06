class ApplicationController < ActionController::API
  include RequesterConcern

  def current_user
    @current_user ||= User.new(
      username:   requester_name,
      type:  requester_role,
      id:    requester_id,
      first_name: requester_first_name,
      last_name:  requester_last_name
    )
  end
end
