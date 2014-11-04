#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'
require 'pp'

# Class that interacts with thetvdb.org.  
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class TheTVDB
    include HTTParty

    base_uri 'http://thetvdb.com/data//'

    def initialize
    end

    def get(query, args=nil)
        response = self.class.get(query, :verify => false)
        return response
    end
end
