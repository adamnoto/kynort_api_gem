require "kynort_gem/normalize_country"

module Kynort::Flights
  module_function

  def search(airline_code, query)
    response = Kynort::Flights::Response.new
    case airline_code.to_s.downcase
      when "aia"
        response.raw = Kynort::Flights::AirAsia.search query
      when "gia"
        response.raw = Kynort::Flights::GarudaIndonesia.search query
      when "lir"
        response.raw = Kynort::Flights::Lion.search query
      when "sya"
        response.raw = Kynort::Flights::Sriwijaya.search query
      when "cnk"
        response.raw = Kynort::Flights::Citilink.search query
      else
        raise "airline code not understood, only {aia, gia, sya, cnk, lir}"
    end
    return response
  rescue => e
    response.is_error = true
    response.error_message = e.message
    if e.is_a?(RestClient::BadRequest)
      response.raw = e.response
    end
    return response
  end

  def pick(airline_code, query)
    response = Kynort::Flights::Response.new
    case airline_code.to_s.downcase
      when "aia"
        response.raw = Kynort::Flights::AirAsia.pick query
      when "gia"
        response.raw = Kynort::Flights::GarudaIndonesia.pick query
      when "lir"
        response.raw = Kynort::Flights::Lion.pick query
      when "sya"
        response.raw = Kynort::Flights::Sriwijaya.pick query
      when "cnk"
        response.raw = Kynort::Flights::Citilink.pick query
      else
        raise "airline code not understood, only {aia, gia, sya, cnk, lir}"
    end
    return response
  rescue => e
    response.is_error = true
    response.error_message = e.message
    if e.is_a?(RestClient::BadRequest)
      response.raw = e.response
    end
    return response
  end

  def suggest_routes(options = {})
    access_token = options.fetch(:access_token)
    origin = options[:origin]

    params = {access_token: access_token}
    params[:origin] = origin if origin

    response = RestClient.get "http://localhost:4001/api/v1/flights/routes", params: params
    response = JSON.parse(response).with_indifferent_access
    response[:airports]
  end
end

require "kynort_gem/flights/air_asia"
require "kynort_gem/flights/citilink"
require "kynort_gem/flights/garuda_indonesia"
require "kynort_gem/flights/lion"
require "kynort_gem/flights/sriwijaya"

require "kynort_gem/flights/passenger"
require "kynort_gem/flights/response"
require "kynort_gem/flights/query"