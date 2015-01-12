require 'spec_helper'
require 'resource_params'

describe ResourceParams do
  describe '#resource_params' do
    let(:resource_name) { Faker::Lorem.words(1).first.singularize }
    let(:model_class) { Class.new }
    let(:model_name) { resource_name.titleize }
    let(:controller_class) { Class.new ApplicationController }
    let(:controller_name) { "#{model_name.pluralize}Controller" }
    let(:permitted_params) { Faker::Lorem.words.map &:to_sym }

    it "returns the model's list of permitted params" do
      controller_class.class_eval { include ResourceParams }
      model_class.stub permitted_params: permitted_params

      with_consts controller_name => controller_class, model_name => model_class do
        controller = controller_class.new

        params = mock 'Params'
        required = mock 'Required'
        params.should_receive(:require).with(resource_name.to_sym).and_return required
        required.should_receive(:permit).with *permitted_params
        controller.stub params: params

        controller.resource_params
      end
    end
  end

  private

  def with_consts(definitions, &block)
    old_consts = {}
    definitions.each do |name, value|
      old_consts.name = value if Object.const_defined? name
      Object.const_set name, value
    end
    yield
  ensure
    definitions.keys.each do |name|
      Object.send :remove_const, name
    end
    old_consts.each do |name, value|
      Object.const_set name, value
    end
  end
end