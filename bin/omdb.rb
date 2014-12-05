#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'

# Class that interacts with omdbapi.com.
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class OMDB
    include HTTParty

    base_uri 'http://www.omdbapi.com//'
    format :json

    def initialize
    end

    def get(query, args=nil)
        new_query = '?i=' + query + '&plot=short&r=json'

        response = self.class.get(new_query, :verify => false)
        return response
    end
end
