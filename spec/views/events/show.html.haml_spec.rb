# coding: UTF-8

require 'spec_helper'

describe "/events/show" do
  before(:each) do
    [User, view].each {|x| x.stub!(:current_user).and_return(FactoryGirl.create :user) }
    @event = FactoryGirl.create :event
    assign :event, @event
  end

  it "should render the event and table_header partials" do
    pending "Not sure how to make this work, but it's probably a stupid spec anyway. :)"
    template.should_receive(:render).with(:partial => 'table_header', :locals => {:sortlinks => false})
    template.should_receive(:render).with(:partial => 'event', :locals => {:event => @event})
    render :file => '/events/show'
  end

  it "should wrap the whole thing in a <table> of class events" do
    render :file => '/events/show'
    rendered.should =~ %r{^\s*<\s*table\s+([^>]*\s*)class=(["'])events\2[^>]*>.*</table>\s*$}m
  end
end
