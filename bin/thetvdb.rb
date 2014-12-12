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

        retry_attempts = 0

        if response.code != 200
            if response.nil?
                return 'nil'
            end
            while retry_attempts < 3 do
                $logger.error "Could not connect to thetvdb.com.  Will retry in 30 seconds"
                sleep(30)
                self.class.get(query)
                retry_attempts += 1
            end
            if retry_attempts >= 3
                $logger.error "Could not connect to thetvdb.  Exiting script."
                exit
            end
        end
        return response
    end
end
