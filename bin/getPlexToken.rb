#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'
require 'highline/import'

require_relative 'plexTv'

# Class to grab the Plex API key
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class MachineID
    include HTTParty

    def initialize
        begin
            $config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
        rescue Errno::ENOENT => e
            abort('Configuration file not found.  Exiting...')
        end

        $plex = PlexTv.new($config)
    end

    def getMachineIDs
        username = ask("Enter your Plex username:") { |q| q.echo = true }
        password = ask("Enter your Plex Password.  NOTE: This will not be saved anywhere") { |q| q.echo = "*" }

        auth = {:username => username, :password => password}
        devices = $plex.get("/devices.xml", auth, true)

        devices['MediaContainer']['Device'].each do | device |
            if device['provides'] == 'server'
                puts "Your API key is: #{device['token']}"
                $config['plex']['api_key'] = device['token']
                File.open(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml'), 'w') {|f| f.write $config.to_yaml } 
                puts "Writing api key to etc/config.yaml"
                exit
            end 
        end

        puts "Cannot find Plex Server"
    end
end

machineid = MachineID.new
machineid.getMachineIDs
