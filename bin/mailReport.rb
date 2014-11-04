#!/usr/bin/ruby
require 'rubygems'
require 'mail'
require 'time'

require_relative 'plexTv'

# Class for sending out the email notification.
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class MailReport
    def initialize(config)
        $config = config
        
        if !$config['mail']['port'].nil?
            $port = $config['mail']['port']
        else
            $port = 25
        end

        if !$config['mail']['subject'].nil?
            $subject = $config['mail']['subject']
        else
            $subject = "Plex Summary "
        end
    end

    # Method for pulling the email information from the config and emailing all Plex users
    def sendMail(body)
        options = { :address              => $config['mail']['address'],
                    :port                 => $port,
                    :domain               => 'otherdomain.com',
                    :user_name            => $config['mail']['username'],
                    :password             => $config['mail']['password'],
                    :authentication       => 'plain',
                    :enable_starttls_auto => true  }
            Mail.defaults do
            delivery_method :smtp, options
        end

        users = Array.new

        # Logic for pulling the email accounts from Plex.tv
        plexTv = PlexTv.new($config)
        plex_users = plexTv.get("/pms/friends/all")
        plex_users['MediaContainer']['User'].each do | user |
            users.push(user['email'])
        end

        users.each do | user |
            mail = Mail.new do
                from "#{$config['mail']['from']} <#{$config['mail']['username']}>"
                to user
                subject $config['mail']['subject'] + Time.now.strftime("%m/%d/%Y")
                content_type 'text/html; charset=UTF-8'
                body body
            end

            mail.deliver!
        end
    end
end
