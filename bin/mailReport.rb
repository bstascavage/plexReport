#!/usr/bin/ruby
require 'rubygems'
require 'mail'
require 'time'

require_relative 'plexTv'

class MailReport
    def initialize
    	begin
       	    $config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
        rescue Errno::ENOENT => e
            abort('Configuration file not found.  Exiting...')
        end
    end

    def sendMail(body)
        options = { :address              => $config['mail']['address'],
                    :port                 => $config['mail']['port'],
                    :domain               => 'otherdomain.com',
                    :user_name            => $config['mail']['username'],
                    :password             => $config['mail']['password'],
                    :authentication       => 'plain',
                    :enable_starttls_auto => true  }
            Mail.defaults do
            delivery_method :smtp, options
        end

        users = Array.new

        plexTv = PlexTv.new($config['plex']['api_key'])
        plex_users = plexTv.get("/pms/friends/all")
        plex_users['MediaContainer']['User'].each do | user |
            users.push(user['email'])
        end

        users.each do | user |
            mail = Mail.new do
                from "#{$config['mail']['from']} <brian@stascavage.com>"
                to user
                subject "Felannisport Update: Week of #{Time.now.strftime("%m/%d/%Y")}"
                content_type 'text/html; charset=UTF-8'
                body body
            end

            mail.deliver!
        end
    end
end
