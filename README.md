plexWeeklyReport
================

Scripts to generate a weekly email of new additions to Plex.

## Introduction
This script is meant to send out a summary of all new Plex entries to your server to all of your server's users.  

## Supported Platforms
* Debian
* Ubuntu 14.04 LTS
* Mac OSX

## Supported Email Clients
* Gmail
* Mozilla Thunderbird

## Supported Plex Agents
* themoviedb
* Freebase
* thetvdb.org

## Prerequisites

The following are needed to run this script:

1.  Ruby installed (at least version 1.9.3) and ruby-dev.
2.  For OSX: make sure you have Ruby installed using RVM (This is needed to create a wrapper to weekly run the script through crontab) (see http://railsapps.github.io/installrubyonrails-mac.html. Follow the steps from "Prepare your computer" until "Rails installation options").
3.  themoviedb set as your Agent for your Movie section on your Plex server.
3.  thetvdb.org set as your Agent for your TV section on your Plex server.
4.  (Optional) A Gmail account to forward the email (Gmail is the only supported provider, so if you use another, YMMV).

## Installation (Linux)

1.  Clone this repo on your server:

    `git clone https://github.com/bstascavage/plexReport.git`
2.  Change to the plexReport directory
3.  Run the initial_setup script:

    `./initial_setup.sh`

4.   If you want to run your script with different commandline parameters, you'll need to edit the crontab.  See here for reference: http://www.adminschoice.com/crontab-quick-reference
    
## Installation (OS X)
Part 1: Install plexReport

1.  Clone this repo on your server:

    `git clone https://github.com/bstascavage/plexReport.git`
2.  Change to the plexReport directory
3.  Install the blunder gem (http://bundler.io/)

    `gem install bundler`
4.  Install the gem dependecies:

    `bundle install`
5.  Setup the config file in `etc/config.yaml`.  See `etc/config.yaml.example` and below for details
6.  Run `bin/plexreport` to execute the script
It should work correctly    
    

Part 2: Create Ruby Wrapper

Now to have the script run once a week through crontab, you have to create an RVM alias by doing the following steps:
(Note: You need an RVM alias because launchd, cron, and other process schedulers operate in discrete bash shell environments. Simply calling ruby from inside your launchd or cron script will not work; that will invoke the non-RVM ruby that OS X shipped with. Instead, you need an RVM alias, which will run your file through RVM's ruby, from inside launchd.)

1.  Determine your ruby version by entering

    `which ruby`
    this should results in:
    `/Users/you/.rvm/rubies/ruby-2.2.0/bin/ruby`
    ruby-2.2.0 is your ruby version
    
2.  Create a wrapper by entering 

    `rvm alias create plexReport ruby-2.2.0@plexReport`
    Note: Replace ruby-2.2.0 with the version that you have determined in step 1 
    
3.  Test the wrapper by entering    
    
    `$rvm_path/wrappers/plexReport/ruby <PATH_TO_REPO>/bin/plexReport.rb -t`
    Note: Replace <PATH_TO_REPO> with the path leading to your plexReport directory 
    
    It should run and exit properly (be patient it might take a few minutes). 
    
4.  Next determine the absolute path to your wrapper. Just run

    `echo $rvm_path`
    it should result in something like this /users/esw1187/.rvm/
    
    Substitute '$rvm_path' in the wrapper call with the absolute rvm path obtaine above and run it again by entering
    
    `/users/ersw1187/.rvm/wrappers/plexReport/ruby /path_to/plexReport/bin/plexReport.rb`
    
5.  Create bash script to run the Rub code by doing the following:
    - Create a file on your desktop named 'plexReport.sh' and open it with TextEdit

    - Copy the following two lines in the file
      `export LC_ALL=en_US.UTF-8`
      `export LANG=en_US.UTF-8`
    
    - Add the wrapper call you just tested in step 4 to the file that you have just tested. E.g. 
      `/users/ersw1187/.rvm/wrappers/plexReport/ruby /path_to/plexReport/bin/plexReport`
    
6.  Copy plexReport.sh to /user/local/bin directory    

7.  Go to the /usr/local/bin directory and set the correct permissions by entering
        `chmod u+x plexReport.sh`

8.  Add the following line to your crontab (sudo crontab -e) 

        `15 11 * * 5 <USERNAME> /usr/local/bin/plexReport.sh` 
    (This will run it every Friday at 11:15. To change the time, see crontab documentation:     
    http://www.adminschoice.com/crontab-quick-reference

## Upgrading

To upgrade your code, cd to your plexReport directory and run `./update.sh`

## Config file

By default, the config file is located in `/etc/plexReport/config.yaml`.  If you need to change any information for the program, or to add more optional config parameters, see below for the config file format:

###### email
`title` - Banner title for the email body.  Required.

`language` - The language of the email body. You need to use ISO 639-1 code ('fr', 'en', 'de'). If a content is not available in the specified language, the script will fall back to english. Defaults to 'en'. Optional.

###### plex
`server` - IP address of your Plex server.  Defaults to 'localhost'.  Optional.

`api_key` - Your Plex API key.  Required.

`sections` - Array of sections to report on.  If field is not set, will report on all TV and movie sections.  Format is ['section1', 'section2'].  Optional.

###### mail
`address` - Address of your smtp relay server.  (ie smtp.gmail.com).  Required.

`port` - Mail port to use.  Default is 25.  (Use 587 for gmail.com).  Required

`username` - Email address to send the email from.  Required.

`password` - Password for hte email set above.  Required.

`from` - Display name of the sender.  Required.

`subject` - Subject of the email.  Note that the script will automatically add a date to the end of the subject.  Required.

`recipients_email` - Email addresses of any additional recipients, outside of your Plex friends.  Optional.

`recipients` - Plex usernames of any Plex friends to be notified.  To be used with the -n option.  Optional

## Command-line Options

Once installed, you can run the script by simply running `plexreport`.  If you need to reinstall or reconfigure the program, run `plexreport-setup`.  All commandline options can be seen by running `plexReport --help`

##### Options:
`-n, --no-plex-email` - Do not send emails to Plex friends.  Can be used with the `recipients_email` and `recipients` config file option to customize email recipients.

`-l, --add-library-names` - Adding the Library name in front of the movie/tv show.  To be used with custom Libraries

`-t, --test-email` - Send email only to the Plex owner (ie yourself).  For testing purposes

`-d, --detailed-email` - Send more details in the email, such as movie ratings, actors, etc

## Images

New Episodes:
![alt tag](http://i.imgur.com/hWzHl2x.png)


New Seasons:
![alt tag](http://i.imgur.com/sBy62Ty.png)


New Movies:
![alt tag](http://i.imgur.com/E3Q85uU.png)

New Movies (detailed view):
![alt tag](http://i.imgur.com/9BHiQHW.png)
