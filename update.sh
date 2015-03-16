#!/bin/bash
# Bash script to pull the newest code from Github and copy it to the correct locations
PLEX_REPORT_LIB='/var/lib/plexReport'
PLEX_REPORT_CONF='/etc/plexReport'

/bin/echo "Grabbing newest code from https://github.com/bstascavage/plexReport"
/usr/bin/git pull

/bin/echo "Moving plexreport and plexreport-setup to /usr/local/sbin"
/bin/cp -r bin/* /usr/local/sbin
/bin/echo "Moving plexreport libraries to /var/lib/plexReport"
/bin/cp -r lib/* $PLEX_REPORT_LIB
/bin/echo "Moving email_body.erb to /etc/plexReport"
/bin/cp -r etc/* $PLEX_REPORT_CONF

/bin/echo "Installing ruby gem dependency"
/usr/bin/gem install bundler
/usr/local/bin/bundle install

/bin/echo "Upgrade complete"
