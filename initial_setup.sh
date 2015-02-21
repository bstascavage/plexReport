#!/bin/bash

PLEX_REPORT_LIB='/var/lib/plexReport'
PLEX_REPORT_CONF='/etc/plexReport'

/bin/mkdir -p $PLEX_REPORT_LIB
/bin/mkdir -p $PLEX_REPORT_CONF

/bin/cp -r bin/* /usr/local/sbin
/bin/cp -r lib/* $PLEX_REPORT_LIB
/bin/cp -r etc/* $PLEX_REPORT_CONF

/usr/bin/touch /etc/plexReport/config.yaml
/usr/bin/touch /var/log/plexReport.log

/use/bin/gem install bundler
/usr/local/bin/bundle install
/usr/local/sbin/plexreport-setup

echo "What day do you want to run the script on? (Put 0 for Sunday, 1 for Monday, etc...)"
read CRON_DAY
echo "What hour should the script run? (00-23)"
read CRON_HOUR
echo "What minute in that hour should the script run? (00-59)"
read CRON_MINUTE

/usr/bin/crontab -l > mycron
#echo new cron into cron file
/bin/echo "$CRON_MINUTE $CRON_HOUR * * $CRON_DAY /usr/local/sbin/plexreport" >> mycron
#install new cron file
/usr/bin/crontab mycron
/bin/rm mycron

echo "Setup complete!"
