# coding: UTF-8

module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    when /the admin page$/
      '/admin'
    when /the event list$/
      events_path
    when 'the event add page'
      new_event_path
    when /#{capture_model}'s page$/
      url_for model! $1
    when /#{capture_model}'s map page$/
      map_event_path model!($1)
    when /^#{capture_model}'s edit page$/
      model = model! $1
      self.send "edit_#{model.class.name.underscore}_path", model
    when /^the (user )?profile page$/
      profile_path
    when /the login page$/
      login_path
    when 'the password reset page'
      reset_password_path
    when /the user list for "([^"]*)"$/
      url_for :controller => 'calendars', :id => Calendar.find_by_name($1).id, :action => 'users', :only_path => true
    when /the calendar edit page for "([^"]*)"$/
      url_for :controller => 'calendars', :id => Calendar.find_by_name($1).id, :action => 'edit', :only_path => true

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
