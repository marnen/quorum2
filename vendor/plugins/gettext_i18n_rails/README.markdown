Simple [FastGettext](http://github.com/grosser/fast_gettext) / Rails integration.

The idea is simple: use Rails I18n::Simple for all default translations,  
and do our own translations with FastGettext!

Rails does: `I18n.t('weir.rails.syntax.i.hate')`  
We do: `_('Just translate my damn text!')`

[See it working in the example application.](https://github.com/grosser/gettext_i18n_rails_example)

Setup
=====
###Installation
This plugin: `  script/plugin install git://github.com/grosser/gettext_i18n_rails.git  `

[FastGettext](http://github.com/grosser/fast_gettext): `  sudo gem install grosser-fast_gettext -s http://gems.github.com/  `

GetText 1.93 or GetText 2.0: `  sudo gem install gettext  `
GetText 2.0 will render 1.93 unusable, so only install if you do not have apps that use 1.93!

### Locales & initialisation
Copy default locales you want from e.g.
[rails i18n](http://github.com/svenfuchs/rails-i18n): rails/locale/de.yml into 'config/locales'

    #environment.rb
    Rails::Initializer.run do |config|
      ...
      config.gem "grosser-fast_gettext", :lib => 'fast_gettext', :version => '~>0.3.0', :source=>"http://gems.github.com/"
      #only used for mo/po file generation in development, !do not load(:lib=>false)! since it will only eat 7mb ram
      config.gem "gettext", :lib => false, :version => '>=1.9.3'
    end
    FastGettext.add_text_domain 'app', :path => 'locale'

    #application_controller
    class ApplicationController < ...
      before_filter :set_gettext_locale
      def set_gettext_locale
        FastGettext.text_domain = 'app'
        FastGettext.available_locales = ['en','de'] #all you want to allow
        super
      end

Translating
===========
 - use some _('translations')
 - run `rake gettext:find`, to let GetText find all translations used
 - (optional) run `rake gettext:store_model_attributes`, to parse the database for columns that can be translated
 - if this is your first translation: `cp locale/app.pot locale/de/app.po` for every locale you want to use
 - translate messages in 'locale/de/app.po' (leave msgstr blank and msgstr == msgid)  
new translations will be marked "fuzzy", search for this and remove it, so that they will be used.
Obsolete translations are marked with ~#, they usually can be removed since they are no longer needed
 - run `rake gettext:pack` to write GetText format translation files

###I18n
Through Ruby magic:
    I18n.locale is the same as FastGettext.locale.to_sym
    I18n.locale = :de  is the same as FastGettext.locale = 'de'

### ActiveRecord
ActiveRecord error messages are translated through Rails::I18n, but
model names and model attributes are translated through FastGettext.
Therefore a validation error on a BigCar's and wheels_size needs `_('big car')` and `_('BigCar|Wheels size')`
to display localized.

These translations can be found through `rake gettext:store_model_attributes`,
which ignores some commonly untranslated columns (id,type,xxx_count,...).
It is recommended to use individual ignores, e.g. ignore whole tables, to do that copy/manipulate the rake task.

Error messages are translated through Rails I18n framework, since i do not want to mess with this atm.
E.g. if your rating model needs a custom validation on rating, it would look like this:
    en:
      activerecord:
        errors:
          models:
            rating:
              attributes:
                rating:
                  inclusion: " -- please choose!"
Best have a look at the [rails I18n guide](http://guides.rubyonrails.org/i18n.html)

Namespaces
==========
Car|Model means Model in namespace Car.  
You do not have to translate this into english "Model", if you use the
namespace-aware translation
    s_('Car|Model') == 'Model' #when no translation was found

Plurals
=======
GetText supports pluralization
    n_('Apple','Apples',3) == 'Apples'

Unfound translations
====================
Sometimes translations like `_("x"+"u")` cannot be fond. You have 4 options:
 - add `N_('xu')` somewhere else in the code, so the parser sees it
 - add `N_('xu')` in a totally seperate file like `locale/unfound_translations.rb`, so the parser sees it
 - use the [gettext_test_log rails plugin ](http://github.com/grosser/gettext_test_log) to find all translations that where used while testing
 - add a Logger to a translation Chain, so every unfound translations is logged ([example]((http://github.com/grosser/fast_gettext)))


TODO
====
 - AR error messages that equal msgids could be translated automatically
 - HamlParser could be improved... (Gettext::Rubyparser does not find translations in converted haml code, so I monkeypatched it to work somewhat)

Author
======
[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...  
