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

shams = {
  :calendar_name => proc {Faker::Name.name + "'s calendar"},
  :city => proc {Faker::Address.city},
  :date => proc {Date.civil(rand(10) + 2000, rand(12) + 1, rand(28) + 1)},
  :description => proc {Faker::Lorem.paragraph},
  :email => proc {Faker::Internet.email},
  :firstname => proc {Faker::Name.first_name},
  :lastname => proc {Faker::Name.last_name},
  :generic_name => proc {Faker::Name.last_name},
  :password => proc {(1..(rand(15) + 4)).map{(32..127).to_a.sample.chr}.join},
  :street => proc {Faker::Address.street_address},
  :street2 => proc {Faker::Address.secondary_address},
  :zip => proc {Faker::Address.zip_code},
  :code => proc {LETTERS.sample + LETTERS.sample}, # 2 random letters
  :event_name => proc {Faker::Lorem.words(3).join(' ')}
}

Event.blueprint do
  name {shams[:event_name]}
  description {shams[:description]}
  street {shams[:street]}
  street2 {shams[:street2]}
  city {shams[:city]}
  state {shams[:state]}
  zip {shams[:zip]}
  date {shams[:date]}
  calendar {shams[:calendar]}
  created_by {User.make!}
end

Acts::Addressed::State.blueprint do
  country {shams[:country]}
  name {shams[:generic_name]}
  code {shams[:code]}
end

Acts::Addressed::Country.blueprint do
  name {shams[:generic_name]}
  code {shams[:code]}
end

Calendar.blueprint do
  name {shams[:calendar_name]}
end

User.blueprint do
  firstname {shams[:firstname]}
  lastname {shams[:lastname]}
  email {shams[:email]}
  password {shams[:password]}
  password_confirmation {self.password}
  street {shams[:street]}
  street2 {shams[:street2]}
  city {shams[:city]}
  state {shams[:state]}
  zip {shams[:zip]}
  active {true}
end

User.blueprint(:inactive) do
  active {false}
end

Commitment.blueprint do
  event {shams[:event]}
  user {shams[:user]}
  status {true}
end

Permission.blueprint do
  user {shams[:user]}
  role {shams[:role]}
  calendar {shams[:calendar]}
end

Permission.blueprint(:admin) do
  role {Role.make! :admin}
end

Role.blueprint do
  name {'user'}
end

Role.blueprint :admin do
  name {'admin'}
end