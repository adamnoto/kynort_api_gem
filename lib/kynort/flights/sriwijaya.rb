class Kynort::Flights::Sriwijaya
  def search(query)
    raise "query must be an instance of Kynort::Flights::Query" unless query.is_a?(Kynort::Flights::Query)
  end

  def pick(query)
    raise "query must be an instance of Kynort::Flights::Query" unless query.is_a?(Kynort::Flights::Query)

  end
end