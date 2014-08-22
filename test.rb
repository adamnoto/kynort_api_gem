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

adl2 = Kynort::Flights::Passenger.new
adl2.title = Kynort::TITLE_MS
adl2.phone = "0854121356541"
adl2.passport = "E8562001"
adl2.first_name = "Sujino"
adl2.born_day = 12
adl2.born_month = 9
adl2.born_year = 1990
adl2.nationality = "ID"
adl2.is_adult = true

ch1 = Kynort::Flights::Passenger.new
ch1.title = Kynort::TITLE_MISTER
ch1.passport = "D78655540"
ch1.first_name = "Auldi"
ch1.last_name = "Suwitno"
ch1.born_day = 8
ch1.born_month = 12
ch1.born_year = 2011
ch1.nationality = "ID"
ch1.is_child = true

if1 = Kynort::Flights::Passenger.new
if1.title = Kynort::TITLE_MISTER
if1.passport = "T912032"
if1.first_name = "Titan"
if1.last_name = "Fairullah"
if1.born_day = 4
if1.born_month = 6
if1.born_day = 2
if1.born_year = 2013
if1.nationality = "ID"
if1.is_infant = true
if1.associated_adult = adl1

sq.add_passenger adl1
sq.add_passenger adl2
sq.add_passenger ch1
sq.add_passenger if1

puts sq.to_hash