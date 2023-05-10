module JsonResponse
  def json_response
    json_response = response.body.present? ? JSON.parse(response.body) : JSON.parse("[]")

    if json_response.is_a?(Array)
      json_response.each(&:with_indifferent_access)
    else
      json_response.with_indifferent_access
    end
  end
end