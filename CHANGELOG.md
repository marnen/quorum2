# Quorum changelog

This is a log of changes in [Quorum](http://quorum2.sourceforge.net) since version 0.3.0, released on 9 September 2011.

Unless otherwise indicated, all changes are by [Marnen Laibow-Koser](http://www.marnen.org). Other contributors to this document should try to maintain the existing format and identify their changes. Numbers in [square brackets] refer to issues in the [tracker](http://marnen.lighthouseapp.com/projects/20949-quorum).

Quorum is distributed under the [BSD 3-Clause License](http://www.opensource.org/licenses/BSD-3-Clause). Share and enjoy!

## v0.3.0, 9 September 2011

* First release under the new numbering format: v0.3.0 (new) = beta3.0.0 (old)
* Upgrade to Rails 3.0
* DO NOT USE! Although tests are passing, the application has serious cosmetic bugs involving Rails 3's autoescaping of HTML. I'll fix these bugs and release a new version.

## v0.3.1, 21 September 2011

* Upgrade to Ruby 1.9 [#58]
* Deal with Rails 3 deprecations [#56]
* Fix problems involving Rails 3's autoescaping of HTML [#57]
* Fix acts_as_addressed issues caused by upgrade [#59]

## v0.3.2, v0.3.3, 21 September 2011
* Fix Capistrano deployment issues

[I mistakenly skipped 0.3.4.]

## v0.3.5, 23 September 2011
* Fix MIME type on RSS feed [#62]

## v0.3.6, 23 September 2011
* Fix Atom link on RSS feed [#62]
* Fix problem with Git tagging on Cap deployment.

## v0.3.7, 23 September 2011
* Fix a couple more broken links to RSS feed [#62]

## v0.3.8, 23 September 2011
* Replace many controller specs with Cucumber stories [#54]
* Deal better with HTML escaping

## v0.3.9, 28 December 2011
* Fix iCal export issues: we were exporting an invalid iCalendar file [#65]

## v0.4.0, 29 December 2011
* Remove make_resourceful now that Rails offers `respond_with` [#64]

## v0.5.0, 12 March 2012
* Add the ability to make comments on one's commitment status [#69]

## v0.5.1, 12 March 2012
* Fix invalid HTML on event list [#71]

## v0.5.2, 12 March 2012
* Autolink URLs in event descriptions [#75]

## v0.5.3, 13 March 2012
* Show commitment status icons on comments [#74]

## v0.5.4, 13 March 2012
* Bugfix.

## v0.5.5, 2 July 2012
* Put event comments on separate lines [#77]
* Add application information in footer [#79]

## v0.5.6, v0.5.7, 2 July 2012
* Bugfix.

## v0.5.8, 2 July 2012
* Put attendance icons in "attending" and "not attending" columns [#81]