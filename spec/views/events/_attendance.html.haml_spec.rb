# coding: UTF-8

require 'spec_helper'

include ERB::Util
include ActionView::Helpers::UrlHelper
include EventsHelper

describe 'events/_attendance' do
  before(:each) do
    render :partial => 'events/attendance', :locals => {:event => FactoryGirl.create(:event)}
  end

  it "should have a select element for event" do
    rendered.should have_selector("select.commit")
  end

  it "should have an empty element for the progress indicator" do
    rendered.should have_selector(".progress", :content => /&nbsp;/)
  end
end