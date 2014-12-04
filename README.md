plexWeeklyReport
================

Scripts to generate a weekly email of new additions to Plex.

## Introduction
This script is meant to send out a summary of all new Plex entries to your server to all of your server's users.  

## Prerequisites

The following are needed to run this script:

1.  Ruby installed (at least version 1.9.3)
2.  themoviedb set as your Agent for your Movie section
3.  thetvdb.org set as your Agent for your TV section
4.  Your Plex API key.  This can be found by searching for your device here: https://plex.tv/devices.xml

## Installation (Linux)

1.  Clone this repo on your server:

    `git clone https://github.com/bstascavage/plexReport.git`
2.  Change to the plexReport directory
3.  Install the blunder gem (http://bundler.io/)

    `gem install bundler`
4.  Install the gem dependecies:

    `bundle install`
5.  Setup the config file in `etc/config.yaml`.  See `etc/config.yaml.example` and below for details
6.  Run `bin/plexReport.rb` to execute the script
7.  To have the script run once a week, run `crontab -e` and add the following line:

    `15 11 * * 5 <PATH_TO_REPO>/bin/plexReport.rb` (This will run it every Friday at 11:15.  To change the time, see crontab documentation: http://www.adminschoice.com/crontab-quick-reference
    
## Config file

###### email
`title` - Banner title for the email body

###### plex
`server` - IP address of your Plex server.  Defaults to 'localhost'

`api_key` - Your Plex API key

###### mail
`address` - Address of your smtp relay server.  (ie smtp.gmail.com)

`port` - Mail port to use.  Default is 25.  (Use 587 for gmail.com)

`username` - Email address to send the email from

`password` - Password for hte email set above

`from` - Display name of the sender

`subject` - Subject of the email.  Note that the script will automatically add a date to the end of the subject

## Images

New Episodes:
![alt tag](http://i.imgur.com/hWzHl2x.png)


New Seasons:
![alt tag](http://i.imgur.com/sBy62Ty.png)


New Movies:
![alt tag](http://i.imgur.com/E3Q85uU.png)
