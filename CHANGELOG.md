# CHANGELOG for spacewalk-server #

This file is used to list changes made in each version of spacewalk-server

## 0.2.6
* Replaced the Perl debian-repo sync script with a overhauled Python version
* Minor bugfixes

## 0.2.5:
* Refactored Ubuntu Errata import. Faster and improved now. 
  (Thx to https://github.com/pandujar for his PR on the import script !)

## 0.2.4:
* Use perl packages from yum rather than installing/compiling with cpanminus

## 0.2.3:
* Made Errata import and repo-sync cron variable and default to 6am / 7am as the mailinglist gzip is created at 5.30

## 0.2.2:
* Moved Errata import prior to repo-sync

## 0.2.1:
* Working repo-sync and errata import for Ubuntu channels

## 0.2.0:
* Fixing and refactoring to work at all and with Spacewalk 2.2

## 0.1.0:

* Initial release
