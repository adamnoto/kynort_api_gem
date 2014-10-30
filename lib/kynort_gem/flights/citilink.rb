module Kynort::Flights::Citilink
  module_function

  def search(request_guid, query)
    raise "Query must be an instance of Kynort::Flights::Query" unless query.is_a?(Kynort::Flights::Query)
    query_hash = query.to_hash
    query_hash[:request_guid] = request_guid
    reply = RestClient.post "http://localhost:4001/api/v1/flights/search/citilink.json", query_hash
    reply
  end

  def quote_final_price(request_guid, query, go_flight_key, return_flight_key = nil)
    raise "Query must be an instance of Kynort::FLights::Query" unless query.is_a?(Kynort::Flights::Query)
    query_hash = query.to_hash
  end

  def pick(request_guid, query)
    raise "Query must be an instance of Kynort::Flights::Query" unless query.is_a?(Kynort::Flights::Query)
    raise "There is no passenger, please fill the passenger data" if query.passengers.nil?
    query_hash = query.to_hash
    query_hash[:request_guid] = request_guid
    reply = RestClient.post "http://localhost:4001/api/v1/flights/book/citilink.json", query_hash
    reply
  end

  # return errors of each passengers grouped by the passenger's index
  def validate_passenger_data(query)
    errors = {}
    query.passengers.each.with_index(0) { |psg, idx| errors[idx.to_s] = psg.validate }
    errors
  end
end