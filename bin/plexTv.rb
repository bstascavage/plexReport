#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'

# Class To interact with Plex.tv
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class PlexTv
    include HTTParty

    base_uri 'http://plex.tv/'
    format :xml

    def initialize(api_key)
        begin
            config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
        rescue Errno::ENOENT => e
            abort('Configuration file not found.  Exiting...')
        end
        $token = config['plex']['api_key']
    end

    def get(query, args=nil)
        if args.nil?
          new_query = query + "?X-Plex-Token=#{$token}"
        else
          new_query = query + "?X-Plex-Token=#{$token}&#{args}"
        end

        response = self.class.get(new_query, :verify => false)
        return response
    end
end
