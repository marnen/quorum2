class CalendarsController < ApplicationController
  @@nonadmin = [:new, :create]
  before_filter :check_admin, :except => @@nonadmin
  before_filter :login_required, :only => @@nonadmin
  layout 'standard'
  
  make_resourceful do
    actions :new, :create, :edit, :update
    
    response_for :new do
      @page_title = _('Create calendar')
      render :action => 'edit'
    end
    
    response_for :edit do
      @page_title = _('Edit calendar')
    end
    
    response_for :create do
      flash[:notice] = _('Your calendar was successfully created.')
      redirect_to '/admin'
    end

    response_for :create_fails do
      flash[:error] = _('Couldn\'t create your calendar!')
      redirect_to :back
    end

    response_for :update do
      flash[:notice] = _('Your calendar was successfully saved.')
      redirect_to '/admin'
    end

    response_for :update_fails do
      flash[:error] = _('Couldn\'t save your calendar!')
      redirect_to :back
    end
  end
  
  # Lists all the users for the current #Calendar.
  def users
    @page_title = _('Users for calendar %{calendar_name}') % {:calendar_name => current_object}
    @users = current_object.users.find(:all, :order => 'lastname, firstname')
  end
end
