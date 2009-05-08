# Object blueprints for Machinist.
require 'faker'
LETTERS = ('A'..'Z').to_a

Event.blueprint do
  name {Sham.event_name}
  state {State.make}
  calendar {Calendar.make}
end

State.blueprint do
  country {Country.make}
  name {Sham.generic_name}
  code
end

Country.blueprint do
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
end

Sham.define do
  calendar_name {Faker::Name.name + "'s calendar"}
  email {Faker::Internet.email}
  firstname {Faker::Name.first_name}
  lastname {Faker::Name.last_name}
  generic_name {Faker::Name.last_name}
  password {(1..(rand(15) + 2)).map{(32..127).to_a.rand.chr}.join}
  code {LETTERS.rand + LETTERS.rand} # 2 random letters
  event_name {Faker::Lorem.words(3).join(' ')}
end