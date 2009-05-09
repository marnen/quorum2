# Object blueprints for Machinist.
require 'faker'
LETTERS = ('A'..'Z').to_a

Event.blueprint do
  name {Sham.event_name}
  state
  date
  calendar
  created_by {User.make}
end

State.blueprint do
  country
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

Commitment.blueprint do
  event
  user
  status {true}
end

Permission.blueprint do
  role
  calendar
end

Role.blueprint do
  name {'user'}
end

Role.blueprint :admin do
  name {'admin'}
end

Sham.define do
  calendar_name {Faker::Name.name + "'s calendar"}
  date(:unique => false) {Date.civil(rand(10) + 2000, rand(12) + 1, rand(28) + 1)}
  email {Faker::Internet.email}
  firstname {Faker::Name.first_name}
  lastname {Faker::Name.last_name}
  generic_name {Faker::Name.last_name}
  password {(1..(rand(15) + 2)).map{(32..127).to_a.rand.chr}.join}
  code {LETTERS.rand + LETTERS.rand} # 2 random letters
  event_name {Faker::Lorem.words(3).join(' ')}
end