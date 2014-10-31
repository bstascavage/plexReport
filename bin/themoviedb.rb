#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'httparty'
require 'pp'

#Class that invokes HTTParty.
class TheMovieDB
    include HTTParty

    base_uri 'https://api.themoviedb.org/3//'
    format :json

    begin
        $config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
    rescue Errno::ENOENT => e
        abort('Configuration file not found.  Exiting...')
    end

    def initialize
    	$token = $config['themoviedb']['api_key']    
    end

    def get(query, args=nil)
        if args.nil?
          new_query = query + "?api_key=#{$token}"
        else
          new_query = query + "?api_key=#{$token}&#{args}"
        end

        response = self.class.get(new_query, :verify => false)
        return response
    end
end
