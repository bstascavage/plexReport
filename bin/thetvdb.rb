#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'
require 'pp'

# Class that interacts with thetvdb.org.  Make sure your API key is set in
# etc/config.yaml. 
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class TheTVDB
    include HTTParty

    base_uri 'http://thetvdb.com/data//'
#    format :json

    begin
        $config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
    rescue Errno::ENOENT => e
        abort('Configuration file not found.  Exiting...')
    end

    def initialize
        $token = $config['thetvdb']['api_key']
    end

    def get(query, args=nil)
        response = self.class.get(query, :verify => false)
        return response
    end
end
