class Kynort::Flights::Response
  attr_accessor :is_error
  attr_accessor :error_message
  attr_accessor :error_backtrace
  attr_accessor :raw

  alias_method :is_error?, :is_error

  def to_hash
    JSON.parse(self.raw)
  end
end
