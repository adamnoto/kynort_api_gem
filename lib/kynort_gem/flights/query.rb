# can be used both for searching flight or booking flight
class Kynort::Flights::Query
  attr_writer :airline
  def airline
    @airline.to_s.downcase
  end
  attr_accessor :request_guid
  def flight_key
    # flight key is separated from each other by 5 dots
    fk_dotted = ""
    @flight_key.each { |each_fk| fk_dotted << "#{each_fk}....." }
    fk_dotted
  end
  def add_flight_key(flight_key)
    @flight_key << flight_key
  end
  attr_writer :use_cache
  def use_cache
    if @use_cache
      return 1
    else
      return 0
    end
  end

  attr_accessor :depart, :arrival
  attr_accessor :from, :to
  attr_writer :adult, :child, :infant
  attr_accessor :captcha

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
  # attr_accessor :contact_hp
  attr_accessor :contact_email

  attr_accessor :use_insurance

  attr_reader :passengers

  def initialize
    self.child = 0
    self.infant = 0
    @passengers ||= []
    @flight_key ||= []

    super
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

  def is_searching?
    (@flight_key.blank? || self.passengers.blank?)
  end

  def validate!
    raise "request_guid cannot be nil/blank" if request_guid.blank?
    raise "airline cannot be nil/blank" if airline.blank?
    raise "airline must be either: cnk, sya, gia, lir, aia" unless %w(cnk sya gia lir aia).include? airline.to_s
    raise "booker_id/issuer_id cannot be blank if not searching" if !is_searching? && (booker_id.blank? || issuer_id.blank?)

    # automatically set use_cache to false, if booking
    if passengers.any? && @flight_key.any?
      self.use_cache = false
    end
    raise "use_cache cannot be nil/blank, it must be either true or false" unless @use_cache.is_a?(TrueClass) || @use_cache.is_a?(FalseClass)

    validate_journey!
    # only validate agent and contact and passengers while not on pick request,
    # search request no need to fill in those values
    unless is_searching?
      validate_agent!
      validate_contact!
      validate_passengers!
    end

    nil
  end

  def add_passenger(passenger)
    raise "passenger must be an instance of Kynort::Flights::Passenger" unless passenger.is_a?(Kynort::Flights::Passenger)
    @passengers ||= []
    @passengers << passenger
  end

  def to_hash
    # validate first
    validate!
    raise "flight key cannot be nil/blank" if (@flight_key.nil? || @flight_key.blank?) && !is_searching?

    data = {
        access_token: Kynort.token,

        flight_key: flight_key,
        use_cache: use_cache,
        depart: depart,
        arrival: arrival,
        from: from,
        adult: adult,
        child: child,
        infant: infant,

        agent_fn: agent_first_name,
        agent_mn: agent_middle_name,
        agent_ln: agent_last_name,
        agent_comp_name: agent_comp_name,
        agent_comp_addr: agent_comp_addr,
        agent_comp_npwp: agent_comp_npwp,
        agent_comp_fax: agent_comp_fax,
        agent_comp_phone: agent_comp_phone,
        agent_comp_email: agent_comp_email,

        # contact_who: contact_who,  # automatically filled by contact person passenger
        # contact_hp: contact_hp,    # automatically filled by contact person passenger
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
    }.with_indifferent_access

    # only if to is specified, add it
    data[:to] = to if to && !to.blank?
    data[:captcha] = captcha if captcha && !captcha.blank?

    unless is_searching?
      # process passengers
      adult_passengers = @passengers.clone.reject! { |psg| !psg.is_adult? }
      entered_adult = entered_child = entered_infant = 0
      any_passenger_as_contact_person = false
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

        any_passenger_as_contact_person = true if !any_passenger_as_contact_person && psg.is_contact_person?

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

        if psg.is_contact_person
          data["contact_who"] = Integer idx
          data["contact_hp"] = psg.phone
        end
      end
      # check number
      raise "number of adults (#{data[:adult]}) do not match with number of inputted data for adult (#{entered_adult})" unless data[:adult] == entered_adult
      raise "number of children (#{data[:child]}) do not match with number of inputted data for children (#{entered_child})" unless data[:child] == entered_child
      raise "number of infant (#{data[:infant]}) do not match with number of inputted data for infant (#{entered_infant})" unless data[:infant] == entered_infant
    end

    data = data.delete_if { |k, v| v.nil? || v.blank? }
  rescue => e
    raise $!, "Error in converting query to hash, error: #{e.message}", $!.backtrace
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
end