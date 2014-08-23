require "normalize_country"

module Kynort::Flights
  class Kynort::Flights::Passenger
    attr_accessor :title
    attr_accessor :phone
    attr_accessor :passport
    attr_accessor :first_name
    attr_accessor :middle_name
    attr_accessor :last_name
    attr_accessor :born_day
    attr_accessor :born_month
    attr_accessor :born_year
    attr_accessor :nationality
    attr_accessor :is_contact_person

    attr_accessor :is_adult
    attr_accessor :is_child
    attr_accessor :is_infant

    alias_method :is_contact_person?, :is_contact_person
    alias_method :is_adult?, :is_adult
    alias_method :is_child?, :is_child
    alias_method :is_infant?, :is_infant

    attr_accessor :associated_adult

    def validate!
      raise "title must be either Mr/Ms/Mrs" unless [TITLE_MISTER, TITLE_MR, TITLE_MRS].include?(title)
      raise "phone cannot be nil/blank" if phone.nil? || phone.blank?
      raise "first name cannot be nil/blank" if first_name.nil? || first_name.blank?
      raise "born month must be an integer" if born_month.nil? || born_month.blank? || !born_month.is_a?(Integer)
      raise "born day must be an integer" if born_day.nil? || born_day.blank? || !born_day.is_a?(Integer)
      raise "born year must be an integer" if born_year.nil? || born_year.blank? || !born_year.is_a?(Integer)
      raise "born day must be between 1 to 31" unless (1..31).include?(born_day)
      raise "born month must be between 1 to 12" unless (1..12).include?(born_year)
      raise "must be either an adult, a child, or an infant" if !is_adult || !is_child || !is_infant || \
        (is_adult && (is_child || is_infant)) || (is_child && (is_adult || is_infant)) || (is_infant && (is_adult || is_child))
      raise "is_adult must be a boolean" if !is_adult.is_a?(TrueClass) || !is_adult.is_a?(FalseClass)
      raise "is_child must be a boolean" if !is_child.is_a?(TrueClass) || !is_child.is_a?(FalseClass)
      raise "is_infant must be a boolean" if !is_infant.is_a?(TrueClass) || !is_infant.is_a?(FalseClass)
      raise "associated_adult must be an adult" if is_infant && (associated_adult.nil? || \
       !associated_adult.is_a?(Kynort::Flights::Passenger) || !associated_adult.is_adult)
    end

    def nationality=(value)
      raise "the nationality of #{first_name} cannot be processed, maybe wrong name?" if Kynort::NormalizeCountry.convert(value).nil?
      @nationality = value
    end

    def is_adult=(val)
      @is_child = false
      @is_infant = false
      @is_adult = val
    end

    def is_child=(val)
      @is_child = val
      @is_infant = false
      @is_adult = false
    end

    def is_infant=(val)
      @is_child = false
      @is_infant = val
      @is_adult = false
    end
  end

  # can be used both for searching flight or booking flight
  class Kynort::Flights::Query
    attr_accessor :access_token
    attr_accessor :business_token

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

    def initialize
      super
      self.child = 0
      self.infant = 0
      @passengers ||= []
    end

    def validate!
      validate_basic_credential
      validate_journey
      validate_agent
      validate_contact
      validate_passengers
    end

    def is_searching?
      self.flight_key.nil?
    end

    def add_passenger(passenger)
      raise "passenger must be an instance of Kynort::Flights::Passenger" unless passenger.is_a?(Kynort::Flights::Passenger)
      @passengers ||= []
      @passengers << passenger
    end

    def to_hash
      # validate first
      validate!

      data = {
        access_token: access_token,
        business_token: business_token,

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

        insurace: use_insurance ? 1 : 0,
        issue_it_now: false
      }.with_indifferent_access

      unless is_searching?
        # process passengers
        adult_passengers = @passengers.clone.reject! { |psg| !psg.is_adult? }
        entered_adult = entered_child = entered_infant = 0
        any_passenger_as_contact_person = false
        @passengers.each do |psg|
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
            data["contact_who"] = psg.first_name + (" #{psg.middle_name}" if psg.middle_name) + (" #{psg.last_name}" if psg.last_name)
            data["contact_hp"] = psg.phone
          end
        end
        # check number
        raise "number of adults do not match with number of inputted data for adult" unless data[:adult] == entered_adult
        raise "number of children do not match with number of inputted data for children" unless data[:child] == entered_child
        raise "number of infant do not match with number of inputted data for infant" unless data[:infant] == entered_infant
      end

      data = data.delete_if { |k, v| v.nil? || v.blank? }
    end

    private
    def validate_basic_credential
      raise "access token cannot be blank/nil" if access_token.nil? || access_token.blank?
      raise "business token cannot be blank/nil" if business_token.nil? || business_token.blank?
      raise "user (carrier agent account) cannot be blank/nil" if user.nil? || user.blank?
      raise "password (carrier agent account password) cannot be nil/blank" if password.nil? || password.blank?
      raise "flight key cannot be nil/blank" if flight_key.nil? || flight_key.blank?
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
end

require "kynort/flights/sriwijaya"