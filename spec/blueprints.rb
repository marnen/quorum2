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
  code {Sham.code}
end

Country.blueprint do
  name {Sham.generic_name}
  code {Sham.code}
end

Calendar.blueprint do
  name {Sham.calendar_name}
end

Sham.define do
  calendar_name {Faker::Name.name + "'s calendar"}
  generic_name {Faker::Name.last_name}
  code {LETTERS.rand + LETTERS.rand} # 2 random letters
  event_name {Faker::Lorem.words(3).join(' ')}
end