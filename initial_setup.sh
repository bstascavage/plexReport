#!/bin/bash
# Bash script that copies plexreport files to various directories
# and walks the user through the initial setup
#

PLEX_REPORT_LIB='/var/lib/plexReport'
PLEX_REPORT_CONF='/etc/plexReport'

/bin/echo "Creating plexreport library at /var/lib/plexReport"
/bin/mkdir -p $PLEX_REPORT_LIB
/bin/echo "Creating plexreport conf directory at /etc/plexReport"
/bin/mkdir -p $PLEX_REPORT_CONF

/bin/echo "Moving plexreport and plexreport-setup to /usr/local/sbin"
/bin/cp -r bin/* /usr/local/sbin
/bin/echo "Moving plexreport libraries to /var/lib/plexreport"
/bin/cp -r lib/* $PLEX_REPORT_LIB
/bin/echo "Moving email_body.erb to /etc/plexreport"
/bin/cp -r etc/* $PLEX_REPORT_CONF

/bin/echo "Creating /etc/plexreport/config.yaml"
/usr/bin/touch /etc/plexReport/config.yaml
/bin/echo "Creating /var/log/plexReport.log"
/usr/bin/touch /var/log/plexReport.log

/bin/echo "Installing ruby gem dependency"
/use/bin/gem install bundler
/usr/local/bin/bundle install

/bin/echo "Running /usr/local/sbin/plexreport-setup"
/usr/local/sbin/plexreport-setup

/bin/echo "What day do you want to run the script on? (Put 0 for Sunday, 1 for Monday, etc...)"
read CRON_DAY
/bin/echo "What hour should the script run? (00-23)"
read CRON_HOUR
/bin/echo "What minute in that hour should the script run? (00-59)"
read CRON_MINUTE

/bin/echo "Adding /usr/local/sbin/plexreport to crontab"
/usr/bin/crontab -l > mycron
/bin/echo "$CRON_MINUTE $CRON_HOUR * * $CRON_DAY /usr/local/sbin/plexreport" >> mycron
/usr/bin/crontab mycron
/bin/rm mycron

/bin/echo "Setup complete!"
