# coding: UTF-8

require 'spec_helper'

module Acts::Addressed
  describe QuietNil do
    it "should be a valid class" do
      QuietNil.class.should == Class
    end
    
    it "should respond as nil to predefined methods" do
      qn = QuietNil.instance
      qn.should be_nil
      pending "can't figure out how to convert to boolean" do
        (!!qn).should be_false
      end
      qn.to_s.should == nil.to_s
      qn.to_a.should == nil.to_a
    end
    
    it "should not whine when it receives methods that aren't defined on nil" do
      qn = QuietNil.instance
      p = lambda {qn.foobarbaz(1, 2, 3)}
      p.should_not raise_error
      
      # We're overriding equality, so we can't do
      # (p.call.equal? qn).should be_true
      # Instead:
      p.call.should be_nil
      lambda {p.call.quux(:quuuux)}.should_not raise_error
    end
  end
end
