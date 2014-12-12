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
        $retry_attempts = 0
    end

    def get(query, args=nil)
        begin
            response = self.class.get(query, :verify => false)
        rescue EOFError
            $logger.error("thetvdb.org is providing wrong headers.  Blah!")
            return nil
        end
        $logger.debug("Response from thetvdb: Code: #{response.code}.")

        if response.code != 200
            if response.nil?
                return 'nil'
            end
            while $retry_attempts < 3 do
                $logger.error("Could not connect to thetvdb.com.  Will retry in 30 seconds")
                sleep(30)
                $retry_attempts += 1
                $logger.debug("Retry attempt: #{$retry_attempts}")
                if self.get(query).code == 200
                    break
                end
            end
            if $retry_attempts >= 3
                $logger.error("Could not connect to thetvdb.  Exiting script.")
                exit
            end
        end

        $retry_attempts = 0
        return response
    end
end
