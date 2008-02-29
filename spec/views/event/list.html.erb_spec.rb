require File.dirname(__FILE__) + '/../../spec_helper'

describe "/event/list" do
  before(:each) do
    render 'event/list'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', /Find me in app\/views\/event\/list/)
  end
end
