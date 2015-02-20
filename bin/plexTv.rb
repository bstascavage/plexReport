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

    def get(query, auth=nil, token_check=false)
        if !token_check
            new_query = query + "?X-Plex-Token=#{$token}"
        else
            new_query = query 
        end

        if auth.nil?
            response = self.class.get(new_query)
        else
            response = self.class.get(new_query, :basic_auth => auth)
        end

        if response.code != 200
            puts "Cannot connect to plex.tv!  Change your connection."
            exit
        end
        return response
    end
end
