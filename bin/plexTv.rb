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

    def initialize(config)
        $token = config['plex']['api_key']
    end

    def get(query, args=nil)
        if args.nil?
          new_query = query + "?X-Plex-Token=#{$token}"
        else
          new_query = query + "?X-Plex-Token=#{$token}&#{args}"
        end

        response = self.class.get(new_query, :verify => false)

        if response.code != 200
            $logger.error("Cannot connect to plex.tv!  Change your connection and your Plex API key.  Exiting.")
            exit
        end
        return response
    end
end
