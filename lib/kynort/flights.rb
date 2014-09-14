require "kynort/normalize_country"

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
    origin = options.fetch(:origin)

    response = RestClient.get "http://localhost:4001/api/v1/flights/routes", params: { access_token: access_token, origin: origin }
    response = JSON.parse(response).with_indifferent_access
    response[:airports]
  end
end

require "kynort/flights/air_asia"
require "kynort/flights/citilink"
require "kynort/flights/garuda_indonesia"
require "kynort/flights/lion"
require "kynort/flights/sriwijaya"

require "kynort/flights/passenger"
require "kynort/flights/response"
require "kynort/flights/query"