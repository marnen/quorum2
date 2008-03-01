class EventController < ApplicationController
  layout "standard"
  def list
    assigns[:events] = Event.find :all, :order => :date
  end

  def new
  end

  def edit
  end
end
