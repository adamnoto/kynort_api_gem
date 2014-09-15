
# can be used both for searching flight or booking flight
class Kynort::Flights::Query
  attr_accessor :user
  attr_accessor :password

  attr_accessor :flight_key

  attr_accessor :depart
  attr_accessor :arrival
  attr_accessor :from
  attr_accessor :adult

  attr_accessor :child, :infant

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
    super
    self.child = 0
    self.infant = 0
    @passengers ||= []
  end

  def is_searching?
    self.flight_key.nil?
  end

  def validate!
    validate_basic_credential
    validate_journey
    # only validate agent and contact and passengers while not on pick request,
    # search request no need to fill in those values
    unless is_searching?
      validate_agent
      validate_contact
      validate_passengers
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
    raise "flight key cannot be nil/blank" if !is_searching? && (flight_key.nil? || flight_key.blank?)

    data = {
        access_token: Kynort.token,

        user: user,
        password: password,
        flight_key: flight_key,
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
        data["#{x}_phones"] << (psg.phone.nil? ? "" : psg.phone) + "....."
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
      raise "number of adults do not match with number of inputted data for adult" unless data[:adult] == entered_adult
      raise "number of children do not match with number of inputted data for children" unless data[:child] == entered_child
      raise "number of infant do not match with number of inputted data for infant" unless data[:infant] == entered_infant
    end

    data = data.delete_if { |k, v| v.nil? || v.blank? }
  rescue => e
    raise e.backtrace.join("\n").to_s
  end

  private
  def validate_basic_credential
    raise "user (carrier agent account) cannot be blank/nil" if user.nil? || user.blank?
    raise "password (carrier agent account password) cannot be nil/blank" if password.nil? || password.blank?
  end

  def validate_journey
    raise "depart cannot be nil/blank" if depart.nil? || depart.blank?
    raise "arrival cannot be nil/blank" if arrival.nil? || arrival.blank?
    raise "from cannot be nil/blank" if from.nil? || from.blank?
    raise "adult cannot be nil/blank" if adult.nil? || adult.blank?
  end

  def validate_agent
    raise "agent's first name cannot be nil/blank" if agent_first_name.nil? || agent_first_name.blank?
    raise "agent's company name cannot be nil/blank" if agent_comp_name.nil? || agent_comp_name.blank?
    raise "agent's company address cannot be nil/blank" if agent_comp_addr.nil? || agent_comp_addr.blank?
    raise "agent's company phone cannot be nil/blank" if agent_comp_phone.nil? || agent_comp_phone.blank?
    raise "agent's company email cannot be nil/blank" if agent_comp_email.nil? || agent_comp_email.blank?
  end

  def validate_contact
    raise "contact's email cannot be nil/blank" if contact_email.nil? || contact_email.blank?
  end

  def validate_passengers
    @passengers.each { |psgr| psgr.validate! }
  end
end