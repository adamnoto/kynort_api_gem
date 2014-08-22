require "kynort"

sq = Kynort::Flights::Query.new
sq.user = "dintvr"
sq.password = "din456123Ct!3"
sq.flight_key = "AD2EfBcxZdsamerUu23Ksmmxns=="
sq.depart = "CGK"
sq.arrival = "SUB"
sq.from = "25-10-2014"
sq.adult = 2
sq.child = 1
sq.infant = 1
sq.agent_first_name = "Ohida"
sq.agent_last_name = "Yoropopo"
sq.agent_comp_name = "Secret Tour and Travel"
sq.agent_comp_addr = "238 ABCD"
sq.agent_comp_phone = "08391212"
sq.agent_comp_email = "secretour@gmail.com"
sq.contact_email = "adam.pahlevi@gmail.com"
sq.use_insurance = false

adl1 = Kynort::Flights::Passenger.new
adl1.title = Kynort::TITLE_MISTER
adl1.phone = "085607071341"
adl1.passport = "A0307865"
adl1.first_name = "Adam"
adl1.middle_name = "Pahlevi"
adl1.last_name = "Baihaqi"
adl1.born_day = 2
adl1.born_month = 12
adl1.born_year = 1992
adl1.nationality = "ID"
adl1.is_contact_person = true
adl1.is_adult = true

sq.add_passenger adl1

puts sq.to_hash