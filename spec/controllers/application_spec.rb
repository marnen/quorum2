require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController, "(admin?)" do
  it "should return nil if current user is nil or false" do
    User.stub!(:current_user).and_return(nil)
    controller.admin?.should be_nil
    User.stub!(:current_user).and_return(false)
    controller.admin?.should be_nil
  end
end
