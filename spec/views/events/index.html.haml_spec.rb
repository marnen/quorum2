require File.dirname(__FILE__) + '/../../spec_helper'

include ERB::Util
include ActionView::Helpers::UrlHelper
include EventsHelper

describe "/events/index" do
  def name_selector(string)
    HTML::Selector.new('[name=?]', string)
  end

  fixtures :states, :countries, :events, :users, :commitments
  before(:each) do
    @events = Event.find(:all)
    assigns[:events] = @events
    assigns[:current_user] = users(:marnen)
    User.stub!(:current_user).and_return(assigns[:current_user])
  end
  
  it "should have loaded at least one event" do
    render 'events/index'
    @events.size.should > 0
  end
  
  it "should have a date limiting form" do
    render 'events/index'
    form = "form[action=#{url_for(:overwrite_params => {}, :escape => false)}][method=get]"
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
    User.current_user.stub!(:calendars).and_return([mock_model(Calendar, :name => 'one', :id => 1), mock_model(Calendar, :name => 'two', :id => 2)])
    render 'events/index'
    form = "form[action=#{events_path}][method=get]"
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
    template.expect_render(:partial => 'event', :collection => @events)
    render 'events/index'
  end
  
  it "should include events/index.js for JavaScript enhancements" do
    render 'events/index'
    response[:javascript].should =~ %r{<script[^>]*events/index\.js}
  end

  it "should contain an autodiscovery link for the RSS feed" do
    render 'events/index'
    response[:head].should have_tag("link[title=RSS][href=#{rss_url}]")
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
  
  it "should contain a link for PDF export" do
    assigns[:query] = '?foo=bar'
    render 'events/index'
    response.should have_tag("a[href=#{url_for(:overwrite_params => {:format => :pdf}, :escape => false)}#{assigns[:query]}]")
  end
end
