#!/usr/bin/ruby
require 'rubygems'
require 'json'

require_relative 'themoviedb'

# Class To interact with Plex, for pulling movie and TV info
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class Plex
    include HTTParty

    base_uri 'http://localhost:32400//'
    format :xml

    begin
        $config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
    rescue Errno::ENOENT => e
        abort('Configuration file not found.  Exiting...')
    end

    def initialize
    end

    def get(query, args=nil)
        response = self.class.get(query, :verify => false)
        return response
    end
end
