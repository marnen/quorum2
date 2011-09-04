require 'machinist/active_record'
require 'ffaker'
LETTERS = ('A'..'Z').to_a

# Add your blueprints here.
#
# e.g.
#   Post.blueprint do
#     title { "Post #{sn}" }
#     body  { "Lorem ipsum..." }
#   end

# TODO: Can we use this shams array to cut down on repetition?
=begin
shams = {
  :calendar_name => lambda {Faker::Name.name + "'s calendar"},
  :city => lambda {Faker::Address.city},
  :date => lambda {Date.civil(rand(10) + 2000, rand(12) + 1, rand(28) + 1)},
  :description => lambda {Faker::Lorem.paragraph},
  :email => lambda {Faker::Internet.email},
  :firstname => lambda {Faker::Name.first_name},
  :lastname => lambda {Faker::Name.last_name},
  :generic_name => lambda {Faker::Name.last_name},
  :password => lambda {(1..(rand(15) + 4)).map{(32..127).to_a.sample.chr}.join},
  :street => lambda {Faker::Address.street_address},
  :street2 => lambda {Faker::Address.secondary_address},
  :zip => lambda {Faker::Address.zip_code},
  :code => lambda {LETTERS.sample + LETTERS.sample}, # 2 random letters
  :event_name => lambda {Faker::Lorem.words(3).join(' ')}
}
=end

Event.blueprint do
  name { Faker::Lorem.words(3).join(' ') }
  description { Faker::Lorem.paragraph }
  street { Faker::Address.street_address }
  street2 { Faker::Address.secondary_address }
  city { Faker::Address.city }
  state
  zip { Faker::Address.zip_code }
  date { Date.civil(rand(10) + 2000, rand(12) + 1, rand(28) + 1) }
  calendar shams[:calendar]
  created_by { User.make }
end

Acts::Addressed::State.blueprint do
  country
  name { Faker::Name.last_name } # generic_name
  code { LETTERS.sample + LETTERS.sample }
end

Acts::Addressed::Country.blueprint do
  name lambda {Faker::Name.last_name} # { Faker::Name.last_name } # generic_name
  code {LETTERS.sample + LETTERS.sample} # { LETTERS.sample + LETTERS.sample }
end

Calendar.blueprint do
  name {Faker::Name.name + "'s calendar"}
end

User.blueprint do
  firstname { Faker::Name.first_name }
  lastname { Faker::Name.last_name }
  email { Faker::Internet.email }
  password { (1..(rand(15) + 4)).map{(32..127).to_a.sample.chr}.join }
  password_confirmation { object.password }
  street { Faker::Address.street_address }
  street2 { Faker::Address.secondary_address }
  city {Faker::Address.city}
  state 
  zip { Faker::Address.zip_code }
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