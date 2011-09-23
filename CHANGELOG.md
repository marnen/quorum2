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

## v0.3.4, 23 September 2011
* Fix MIME type on RSS feed [#62]