module Kynort::Flights::Routes
  module_function

  def suggest_routes(origin)
    params = {access_token: Kynort.token}
    params[:origin] = origin if origin

    response = RestClient.get "http://localhost:4001/api/v1/flights/routes", params: params
    response = JSON.parse(response).with_indifferent_access
    response[:airports]
  end

  def suggest_routes_by_country(origin)

  end
end