class EventController < ApplicationController
  layout "standard"
  def list
    assigns[:events] = Event.find :all
  end

  def new
  end

  def edit
  end
end
