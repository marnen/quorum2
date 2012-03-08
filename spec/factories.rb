# coding: UTF-8

require 'ffaker'
LETTERS = ('A'..'Z').to_a

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
FactoryGirl.define do
  factory :event do
    name { Faker::Lorem.words(3).join(' ') }
    description { Faker::Lorem.paragraph }
    street { Faker::Address.street_address }
    street2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    association :state_raw, :factory => :state
    zip { Faker::Address.zip_code }
    date { Date.civil(rand(10) + 2100, rand(12) + 1, rand(28) + 1) } # way in the future so it shows up on the event list
    calendar
    association :created_by, :factory => :user

    factory :deleted_event do
      deleted { true }
    end
  end

  factory :state, :class => Acts::Addressed::State do
    country
    name { Faker::Name.last_name } # generic_name
    code { LETTERS.sample + LETTERS.sample }
  end

  factory :country, :class => Acts::Addressed::Country do
    name { Faker::Name.last_name } # generic_name
    code { LETTERS.sample + LETTERS.sample }
  end

  factory :calendar do
    name {Faker::Name.name + "'s calendar"}
  end

  factory :user do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    email { Faker::Internet.email }
    password {'passw0rd'}
    password_confirmation { password }
    street { Faker::Address.street_address }
    street2 { Faker::Address.secondary_address }
    city {Faker::Address.city}
    association :state_raw, :factory => :state
    zip { Faker::Address.zip_code }
    active {true}

    factory :inactive_user do
      active {false}
    end

    factory :user_with_random_password do
      password { (1..(rand(15) + 4)).map{(32..127).to_a.sample.chr}.join }
    end
  end

  factory :commitment do
    event
    user
    status {true}
    comment { Faker::Lorem.sentence }
  end

  factory :permission do
    user
    role
    calendar
    show_in_report {true}

    factory :admin_permission do
      association :role, :factory => :admin_role
    end
  end

  factory :role do
    name {'user'}

    factory :admin_role do
      name {'admin'}
    end
  end
end