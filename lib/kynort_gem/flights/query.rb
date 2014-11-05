# can be used both for searching flight or booking flight
module Kynort::Flights::Query
  attr_writer :airline
  attr_accessor :request_guid
  attr_accessor :depart, :arrival
  attr_accessor :from, :to
  attr_writer :adult, :child, :infant
  attr_accessor :captcha
  attr_writer :use_cache

  def initialize
    self.child = 0
    self.infant = 0
    @validation_methods = [:validate_query!]
    @parameterize_methods = [:to_hash_query]

    puts "INITIALIZING QUERY"
  end

  def journey_mode
    unless self.arrival.blank? || self.to.blank?
      return :roundtrip
    end
    return :oneway
  end

  def use_cache
    @use_cache ? 1 : 0
  end
  def adult
    Integer(@adult)
  end
  def child
    Integer(@child || 0)
  end
  def infant
    Integer(@infant || 0)
  end

  def airline
    @airline.to_s.downcase
  end

  def validate!
    @validation_methods.each { |method| send method }
  end

  def validate_query!
    raise "request_guid cannot be nil/blank" if request_guid.blank?
    raise "airline cannot be nil/blank" if airline.blank?
    raise "airline must be one of: cnk, sya, gia, lir, aia" unless %w(cnk sya gia lir aia).include? airline.to_s
    raise "use_cache must either be true or false" unless @use_cache.is_a?(TrueClass) || @use_cache.is_a?(FalseClass)
    nil
  end

  def to_hash
    validate!

    data = {}
    @parameterize_methods.each { |method| data.merge!(send(method)) }
  rescue => e
    raise $!, "Error in converting query to hash, error: #{e.message}", $!.backtrace
  end

  def to_hash_query
    data = {
        access_token: Kynort.token,

        use_cache: use_cache,
        depart: depart,
        arrival: arrival,
        from: from,
        adult: adult,
        child: child,
        infant: infant,
    }.with_indifferent_access

    # only if to is specified, add it
    data[:to] = to if to && !to.blank?
    data[:captcha] = captcha if captcha && !captcha.blank?

    data
  end

  private
  def add_validation(method_name)
    if respond_to? method_name
      @validation_methods << method_name
    end
  end

  def add_parameterise_method(method_name)
    @parameterize_methods << method_name if respond_to? method_name
  end
end

module Kynort::Flights::QueryHasFlightKeys
  attr_accessor :search_guid      # only for booking/issuing

  def add_go_key(go_flight_key)
    @go_flight_keys << go_flight_key
  end

  def add_return_key(return_flight_key)
    @return_flight_keys << return_flight_key
  end

  def go_flight_keys
    fk_dotted = ""
    @go_flight_keys.each { |fk| fk_dotted << "#{fk}....." }
    fk_dotted
  end

  def return_flight_keys
    fk_dotted = ""
    @return_flight_keys.each { |fk| fk_dotted << "#{fk}....." }
    fk_dotted
  end

  # only when booking a flight/issuing a ticket.
  attr_accessor :booker_id
  attr_accessor :issuer_id

  attr_accessor :agent_first_name
  attr_accessor :agent_middle_name # optional
  attr_accessor :agent_last_name # optional
  attr_accessor :agent_comp_name
  attr_accessor :agent_comp_addr
  attr_accessor :agent_comp_npwp # optional
  attr_accessor :agent_comp_fax # optional
  attr_accessor :agent_comp_phone
  attr_accessor :agent_comp_email

  # only adult passenger can be given right to be a contact person (0-indexed)
  # attr_accessor :contact_who
  attr_accessor :contact_first_name
  attr_accessor :contact_middle_name
  attr_accessor :contact_last_name
  attr_accessor :contact_email

  attr_accessor :use_insurance

  attr_reader :passengers
  attr_accessor :passenger_phone

  def initialize
    @passengers ||= []

    @go_flight_keys = []
    @return_flight_keys = []

    puts "INITIALIZING QUERY HAS FLIGHT KEYS"
  end

  def add_passenger(passenger)
    raise "passenger must be an instance of Kynort::Flights::Passenger" unless passenger.is_a?(Kynort::Flights::Passenger)
    @passengers ||= []
    @passengers << passenger
  end

  def validate_query_has_flight_keys!
    return "go flight keys cannot be nil/blank" if (@go_flight_keys.nil? || @go_flight_keys.empty?)
    raise "booker_id/issuer_id cannot be blank if not searching" if booker_id.blank? && issuer_id.blank?
    raise "search_guid cannot be nil/blank" if self.search_guid.blank?
  end

  def validate_journey!
    raise "depart cannot be nil/blank" if depart.nil? || depart.blank?
    raise "arrival cannot be nil/blank" if arrival.nil? || arrival.blank?
    raise "from cannot be nil/blank" if from.nil? || from.blank?
    raise "adult cannot be nil/blank" if adult.nil? || adult.blank?
  end

  def validate_agent!
    raise "agent's first name cannot be nil/blank" if agent_first_name.nil? || agent_first_name.blank?
    raise "agent's company name cannot be nil/blank" if agent_comp_name.nil? || agent_comp_name.blank?
    raise "agent's company address cannot be nil/blank" if agent_comp_addr.nil? || agent_comp_addr.blank?
    raise "agent's company phone cannot be nil/blank" if agent_comp_phone.nil? || agent_comp_phone.blank?
    raise "agent's company email cannot be nil/blank" if agent_comp_email.nil? || agent_comp_email.blank?
  end

  def validate_contact!
    raise "contact's email cannot be nil/blank" if contact_email.nil? || contact_email.blank?
  end

  def validate_passengers!
    @passengers.each { |psgr| psgr.validate! }
  end

  def to_hash_query_has_flight_keys
    data = {
        go_flight_keys: go_flight_keys,
        return_flight_keys: return_flight_keys,
        agent_fn: agent_first_name,
        agent_mn: agent_middle_name,
        agent_ln: agent_last_name,
        agent_comp_name: agent_comp_name,
        agent_comp_addr: agent_comp_addr,
        agent_comp_npwp: agent_comp_npwp,
        agent_comp_fax: agent_comp_fax,
        agent_comp_phone: agent_comp_phone,
        agent_comp_email: agent_comp_email,

        contact_email: contact_email,

        a_titles: "",
        a_phones: "",
        a_passports: "",
        a_fns: "",
        a_mns: "",
        a_lns: "",
        a_dborns: "",
        a_mborns: "",
        a_yborns: "",
        a_nats: "",

        c_titles: "",
        c_phones: "",
        c_passports: "",
        c_fns: "",
        c_mns: "",
        c_lns: "",
        c_dborns: "",
        c_mborns: "",
        c_yborns: "",
        c_nats: "",

        i_titles: "",
        i_passports: "",
        i_fns: "",
        i_mns: "",
        i_lns: "",
        i_dborns: "",
        i_mborns: "",
        i_yborns: "",
        i_assocs: "",
        i_nats: "",

        insurance: use_insurance ? 1 : 0,
        issue_it_now: false
    }

    data[:contact_fn] = contact_first_name if contact_first_name.is_a?(String)
    data[:contact_mn] = contact_middle_name if contact_middle_name.is_a?(String)
    data[:contact_ln] = contact_last_name if contact_last_name.is_a?(String)
    data[:passenger_phone] = passenger_phone if passenger_phone
    data[:search_guid] = search_guid if search_guid

    # process passengers
    adult_passengers = @passengers.clone.reject! { |psg| !psg.is_adult? }
    entered_adult = entered_child = entered_infant = 0
    @passengers.each.with_index(1) do |psg, idx|
      if psg.is_adult?
        entered_adult += 1
        x = "a"
      elsif psg.is_child?
        entered_child += 1
        x = "c"
      elsif psg.is_infant?
        entered_infant += 1
        x = "i"
      else
        raise "unsure"
      end

      data["#{x}_titles"] << (psg.title.nil? ? "" : psg.title) + "....."
      data["#{x}_phones"] << (psg.phone.nil? ? "" : psg.phone) + "....." if x != 'i'
      data["#{x}_passports"] << (psg.passport.nil? ? "" : psg.passport.to_s) + "....."
      data["#{x}_fns"] << (psg.first_name.nil? ? "" : psg.first_name) + "....."
      data["#{x}_mns"] << (psg.middle_name.nil? ? "" : psg.middle_name) + "....."
      data["#{x}_lns"] << (psg.last_name.nil? ? "" : psg.last_name) + "....."
      data["#{x}_dborns"] << (psg.born_day.nil? ? "" : psg.born_day.to_s) + "....."
      data["#{x}_mborns"] << (psg.born_month.nil? ? "" : psg.born_month.to_s) + "....."
      data["#{x}_yborns"] << (psg.born_year.nil? ? "" : psg.born_year.to_s) + "....."
      data["#{x}_nats"] << (psg.nationality.nil? ? "" : psg.nationality) + "....."

      if x == "i"
        data["#{x}_assocs"] = adult_passengers.index(psg.associated_adult) + 1
      end

      data[:booker_id] = booker_id if booker_id
      data[:issuer_id] = issuer_id if issuer_id

    end
    # check number
    raise "number of adults (#{data[:adult]}) do not match with number of inputted data for adult (#{entered_adult})" unless data[:adult] == entered_adult
    raise "number of children (#{data[:child]}) do not match with number of inputted data for children (#{entered_child})" unless data[:child] == entered_child
    raise "number of infant (#{data[:infant]}) do not match with number of inputted data for infant (#{entered_infant})" unless data[:infant] == entered_infant
  end

  data = data.delete_if { |k, v| v.nil? || v.blank? }
  data
end

class Kynort::Flights::Query::Search
  include Kynort::Flights::Query
end

class Kynort::Flights::Query::Quote
  include Kynort::Flights::Query

  attr_accessor :go_flight_key
  attr_accessor :return_flight_key

  def validate_quote!
    raise "go_flight_key cannot be blank" if go_flight_key.nil? || go_flight_key.blank?
    raise "return_flight_key cannot be blank if roundtrip" if (return_flight_key.nil? || return_flight_key.blank?) && journey_mode == :roundtrip
  end

  def to_hash_quote
    data = {
      flight_go_key: go_flight_key,
    }

    data[:flight_return_key] = return_flight_key if return_flight_key && !return_flight_key.blank?
    data
  end

  def initialize
    super()
    self.use_cache = false

    add_validation :validate_quote!
    add_parameterise_method :to_hash_quote
  end
end

class Kynort::Flights::Query::Book
  include Kynort::Flights::Query
  include Kynort::Flights::QueryHasFlightKeys

  def initialize
    super()
    self.use_cache = false

    add_validation :validate_query_has_flight_keys!
    add_validation :validate_journey!
    add_validation :validate_agent!

    add_parameterise_method :to_hash_query_has_flight_keys
  end
end

class Kynort::Flights::Query::Issue
  include Kynort::Flights::Query
  include Kynort::Flights::QueryHasFlightKeys

  def initialize()
    super()
    self.use_cache = false

    add_validation :validate_query_has_flight_keys!
    add_validation :validate_journey!
    add_validation :validate_agent!

    add_parameterise_method :to_hash_query_has_flight_keys
  end
end