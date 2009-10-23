# Object blueprints for Machinist.
require 'machinist/active_record'
require 'sham'
require 'faker'
LETTERS = ('A'..'Z').to_a

Event.blueprint do
  name {Sham.event_name}
  description
  street
  street2
  city
  state
  zip
  date
  calendar
  created_by {User.make}
end

Acts::Addressed::State.blueprint do
  country
  name {Sham.generic_name}
  code
end

Acts::Addressed::Country.blueprint do
  name {Sham.generic_name}
  code
end

Calendar.blueprint do
  name {Sham.calendar_name}
end

User.blueprint do
  firstname
  lastname
  email
  password
  password_confirmation {self.password}
  street
  street2
  city
  state
  zip
  active {true}
end

User.blueprint(:inactive) do
  active {false}
end

Commitment.blueprint do
  event
  user
  status {true}
end

Permission.blueprint do
  user
  role
  calendar
end

Permission.blueprint(:admin) do
  role {Role.make :admin}
end

Role.blueprint do
  name {'user'}
end

Role.blueprint :admin do
  name {'admin'}
end

Sham.define do
  calendar_name {Faker::Name.name + "'s calendar"}
  city {Faker::Address.city}
  date(:unique => false) {Date.civil(rand(10) + 2000, rand(12) + 1, rand(28) + 1)}
  description {Faker::Lorem.paragraph}
  email {Faker::Internet.email}
  firstname {Faker::Name.first_name}
  lastname {Faker::Name.last_name}
  generic_name {Faker::Name.last_name}
  password {(1..(rand(15) + 4)).map{(32..127).to_a.rand.chr}.join}
  street {Faker::Address.street_address}
  street2 {Faker::Address.secondary_address}
  zip {Faker::Address.zip_code}
  code {LETTERS.rand + LETTERS.rand} # 2 random letters
  event_name {Faker::Lorem.words(3).join(' ')}
end