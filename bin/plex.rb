#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'

# Class To interact with a Plex server, for pulling movie and TV info and stuff
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class Plex
    include HTTParty

    def initialize(config)
        $config = config
        if !$config['plex']['server'].nil?
            self.class.base_uri "http://#{$config['plex']['server']}:32400/"
        end
    end

    base_uri "http://localhost:32400/"
    format :xml

    def get(query, args=nil)
        response = self.class.get(query, :verify => false)
        return response
    end
end
