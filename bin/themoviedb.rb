#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'

# Class that interacts with themoviedb.org.  Make sure your API key is set in
# etc/config.yaml.  Note that themoviedb.org limits API calls to 30 every 10 seconds,
# hence the sleep in this code.
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class TheMovieDB
    include HTTParty

    base_uri 'https://api.themoviedb.org/3//'
    format :json

    def initialize(config)
    	$token = config['themoviedb']['api_key']    
    end

    def get(query, args=nil)
        if args.nil?
          new_query = query + "?api_key=#{$token}"
        else
          new_query = query + "?api_key=#{$token}&#{args}"
        end

        response = self.class.get(new_query, :verify => false)
	sleep 0.4
        return response
    end
end
