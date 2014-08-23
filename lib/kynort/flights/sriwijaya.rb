class Kynort::Flights::Sriwijaya
  class << self
    def search(query)
      raise "query must be an instance of Kynort::Flights::Query" unless query.is_a?(Kynort::Flights::Query)
      query_hash = query.to_hash
      reply = RestClient.post "http://localhost:4001/api/v1/flights/search/sriwijaya.json", query_hash
    end

    def pick(query)
      raise "query must be an instance of Kynort::Flights::Query" unless query.is_a?(Kynort::Flights::Query)
    end
  end
end