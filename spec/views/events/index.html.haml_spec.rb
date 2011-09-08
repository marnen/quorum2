require 'spec_helper'

include ERB::Util
include ActionView::Helpers::UrlHelper
include EventsHelper

describe "/events/index" do
  def name_selector(string)
    HTML::Selector.new('[name=?]', string)
  end

  before(:each) do
    @events = (1..10).map { Factory :event }
    assigns[:events] = @events
    @user = Factory :user
    assigns[:current_user] = @user
    User.stub!(:current_user).and_return @user
  end
  
 it "should have a date limiting form" do
    render 'events/index'
    form = "form[action=#{url_for(params.merge :escape => false)}][method=get]"
    response.should have_tag("#{form}") do |e|
      e.should have_tag('input') do |inputs|
        inputs.should have_tag('[type=radio]') do |radios|
          radios.should have_tag(name_selector('search[from_date_preset]')) do |from_date|
            from_date.should have_tag('[value=today][checked]')
            from_date.should have_tag('[value=earliest]')
            from_date.should have_tag('[value=other]')
          end
          radios.should have_tag(HTML::Selector.new('[name=?]', 'search[to_date_preset]')) do |to_date|
            to_date.should have_tag('[value=latest][checked]')
            to_date.should have_tag('[value=other]')
          end
        end
        inputs.should have_tag(HTML::Selector.new('[type=submit]:not([name])'))
      end
      e.should have_tag('select') do |selects|
        (1..3).each do |x|
          selects.should have_tag(name_selector "search[from_date(#{x}i)]")
          selects.should have_tag(name_selector "search[to_date(#{x}i)]")
          selects.should_not have_tag(name_selector "search[calendar_id]")
        end
      end
    end
  end
  
  it "should have a calendar option on the limiting form iff user has multiple calendars" do
    User.current_user.stub!(:calendars).and_return((1..2).map{ Factory :calendar })
    render 'events/index'
    form = "form[action=#{url_for(params.merge :escape => false)}][method=get]"
    response.should have_tag("#{form} select") do |selects|
      selects.should have_tag(name_selector "search[calendar_id]")
    end
  end
  
  it "should show a sort link in date and event column header" do
    render 'events/index'
    response.should have_tag("th a.sort", h("Date"))
    response.should have_tag("th a.sort", h("Event"))
  end
  
  it "should show a sort indicator next to headers that have been sorted by" do
    assigns[:order] = 'name'
    assigns[:direction] = 'desc'
    render 'events/index' # , {:order => 'name', :direction => 'desc'}
    response.should have_text(%r{Event\s?((<[^>]*>)?\s?)*↓})
  end
  
  it "should render _event for each event" do
    template.should_receive(:render).with(:partial => 'event', :collection => @events)
    render 'events/index'
  end
  
  it "should include events/index.js for JavaScript enhancements" do
    render 'events/index'
    response.capture(:javascript).should =~ %r{<script[^>]*events/index\.js}
  end

  it "should contain an autodiscovery link for the RSS feed" do
    render 'events/index'
    response.capture(:head).should have_tag("link[title=RSS][href=#{rss_url}]")
  end
  
  it "should contain a link and a URL for the RSS feed" do
    render 'events/index'
    response.should have_tag(".rss a[href=#{rss_url}]")
    response.should have_tag(".rss .url", %r{#{rss_url}})
  end
  
  it "should contain a link to regenerate the RSS feed key" do
    render 'events/index'
    response.should have_tag(".rss a[href=#{regenerate_key_path}]")
  end
  
  it "should contain a link for PDF export if the current events belong to exactly one calendar" do
    @one = mock_model(Calendar, :name => 'one', :id => 1)
    @events.each do |e|
      e.stub!(:calendar).and_return(@one)
    end
    render "events/index"
    response.should have_tag("a[href=#{url_for(params.merge :format => :pdf, :escape => false)}]")
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
    render "events/index"
    response.should_not have_tag("a[href=#{url_for(params.merge :format => :pdf, :escape => false)}]")
  end
end
