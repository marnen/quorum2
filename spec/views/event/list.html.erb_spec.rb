require File.dirname(__FILE__) + '/../../spec_helper'

describe "/event/list" do
  fixtures :events, :states, :countries
  
  before(:each) do
    @events = Event.find :all
    assigns[:events] = @events
    render 'event/list'
  end
  
  it "should have loaded at least one event" do
   @events.size.should > 0
  end
  
  it "should show a name for each Event in a tag of class 'summary'" do
    for event in @events do
      response.should have_tag("#event_#{event.id} .summary", ERB::Util.h(event.name))
    end
  end
  
  it "should show a city for each event in a tag of class 'locality'" do
    for event in @events do
      response.should have_tag("#event_#{event.id} .locality", ERB::Util.h(event.city))
    end
  end
  
  it "should show a state code for each event in a tag of class 'region'" do
    for event in @events do
      response.should have_tag("#event_#{event.id} .region", ERB::Util.h(event.state.code))
    end
  end

  it "should show a country code for each event in a tag of class 'country-name'" do
    for event in @events do
      response.should have_tag("#event_#{event.id} .country-name", ERB::Util.h(event.state.country.code))
    end
  end
end
