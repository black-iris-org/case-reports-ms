module JsonResponse
  def json_response
    json_response = JSON.parse(response.body)

    if json_response.is_a?(Array)
      json_response.each(&:with_indifferent_access)
    else
      json_response.with_indifferent_access
    end
  end
end