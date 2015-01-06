# coding: UTF-8

# Object blueprints for Machinist.
require 'machinist/active_record'
require 'sham'
require 'ffaker'
LETTERS = ('A'..'Z').to_a

module Acts::Addressed
  Country.blueprint do
    name {Sham.generic_name}
    code
  end

  State.blueprint do
    country
    name {Sham.generic_name}
    code
  end
end

Sham.define do
  generic_name {Faker::Name.last_name}
  code {LETTERS.shuffle.take(2).join} # 2 random letters
end