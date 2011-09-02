shared_context 'gettext', :type => 'controller' do
  before(:all) do
    FastGettext.text_domain ||= SITE_TITLE
    FastGettext.available_locales ||= ['en']
  end
end