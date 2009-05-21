module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the homepage/
      '/'
      
    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))
    
    when /\badmin page/
      '/admin'
    
    when /\bevent list/
      events_path
      
    when /\blogin page/
      login_path
      
    when /\buser list for "([^"]*)"/
      url_for :controller => 'calendars', :id => Calendar.find_by_name($1).id, :action => 'users', :only_path => true

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
