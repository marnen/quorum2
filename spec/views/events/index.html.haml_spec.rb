# coding: UTF-8

require 'spec_helper'

include ERB::Util
include ActionView::Helpers::UrlHelper
include EventsHelper

describe "/events/index" do
  def name_selector(string)
    "[name='#{string}']"
  end

  before(:each) do
    @events = (1..10).map { Factory :event }
    assign :events, @events
    @user = Factory :user
    assign :current_user, @user
    [view, User].each {|x| x.stub!(:current_user).and_return @user }
  end
  
 it "should have a date limiting form" do
    render :file => 'events/index'
    form = "form[action='#{url_for(params.merge :escape => false)}'][method=get]"
    rendered.should have_selector("#{form}") do |e|
      e.should have_selector('input') do |inputs|
        inputs.should have_selector('[type=radio]') do |radios|
          radios.should have_selector(name_selector('search[from_date_preset]')) do |from_date|
            from_date.should have_selector('[value=today][checked]')
            from_date.should have_selector('[value=earliest]')
            from_date.should have_selector('[value=other]')
          end
          radios.should have_selector(name_selector 'search[to_date_preset]') do |to_date|
            to_date.should have_selector('[value=latest][checked]')
            to_date.should have_selector('[value=other]')
          end
        end
        inputs.should have_selector(HTML::Selector.new('[type=submit]:not([name])'))
      end
      e.should have_selector('select') do |selects|
        (1..3).each do |x|
          selects.should have_selector(name_selector "search[from_date(#{x}i)]")
          selects.should have_selector(name_selector "search[to_date(#{x}i)]")
          selects.should_not have_selector(name_selector "search[calendar_id]")
        end
      end
    end
  end
  
  it "should have a calendar option on the limiting form iff user has multiple calendars" do
    User.current_user.stub!(:calendars).and_return((1..2).map{ Factory :calendar })
    render :file => 'events/index'
    form = "form[action='#{url_for(params.merge :escape => false)}'][method=get]"
    rendered.should have_selector("#{form} select") do |selects|
      selects.should have_selector(name_selector "search[calendar_id]")
    end
  end
  
  it "should show a sort link in date and event column header" do
    render :file => 'events/index'
    rendered.should have_selector("th a.sort", :content => 'Date')
    rendered.should have_selector("th a.sort", :content => "Event")
  end
  
  it "should show a sort indicator next to headers that have been sorted by" do
    assign :order, 'name'
    assign :direction, 'desc'
    render :file => 'events/index'
    rendered.should =~ %r{Event\s?((<[^>]*>)?\s?)*↓}
  end
  
  it "should render _event for each event" do
    pending "Not sure how to make this work." do
      template.should_receive(:render).with(:partial => 'event', :collection => @events)
      render :file => 'events/index'
    end
  end
  
  it "should include events/index.js for JavaScript enhancements" do
    render :file => 'events/index'
    view.content_for(:javascript).should have_selector("script[src*='events/index.js']")
  end

  it "should contain an autodiscovery link for the RSS feed" do
    render :file => 'events/index'
    view.content_for(:head).should have_selector("link[title='RSS'][href='#{rss_url}']")
  end
  
  it "should contain a link and a URL for the RSS feed" do
    render :file => 'events/index'
    rendered.should have_selector(".rss a[href='#{rss_url}']")
    rendered.should have_selector(".rss .url", :content => rss_url)
  end
  
  it "should contain a link to regenerate the RSS feed key" do
    render :file => 'events/index'
    rendered.should have_selector(".rss a[href='#{regenerate_key_path}']")
  end
  
  it "should contain a link for PDF export if the current events belong to exactly one calendar" do
    @one = Factory :calendar
    @events.each do |e|
      e.stub!(:calendar).and_return(@one)
    end
    render :file => "events/index"
    rendered.should have_selector("a[href='#{url_for(params.merge :format => :pdf, :escape => false)}']")
  end
  
  it "should not contain a link for PDF export if the current events belong to more than one calendar" do
    @one = mock_model(Calendar, :name => 'one', :id => 1)
    @two = mock_model(Calendar, :name => 'two', :id => 2)
    @events.each_index do |i|
      e = @events[i]
      if i % 2 == 0
        e.stub!(:calendar).and_return(@one)
      else
        e.stub!(:calendar).and_return(@two)
      end
    end
    render :file => "events/index"
    rendered.should_not have_selector("a[href='#{url_for(params.merge :format => :pdf, :escape => false)}']")
  end
end
