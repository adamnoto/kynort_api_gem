module Kynort::Flights::Routes
  module_function

  def suggest_routes(origin = nil)
    params = {access_token: Kynort.token}
    params[:origin] = origin if origin

    response = RestClient.get "http://localhost:4001/api/v1/flights/routes", params: params
    response = JSON.parse(response).with_indifferent_access
    response[:airports]
  end

  def suggest_routes_by_country(origin = nil)
    params = {access_token: Kynort.token}
    params[:origin] = origin if origin

    response = RestClient.get "#{Kynort.config.host}/api/v1/flights/routes/by_country", params: params
    response = JSON.parse(response).with_indifferent_access
    response[:airports]
  end
end