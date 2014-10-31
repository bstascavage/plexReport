#!/usr/bin/ruby
require 'rubygems'
require 'pp'
require 'time'
require 'yaml'
require 'erb'

require_relative 'plexsummary'

class ReadLog
    def initialize
        begin
            $config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
        rescue Errno::ENOENT => e
            abort('Configuration file not found.  Exiting...')
        end
    end
      
    def getMovies
	test = PlexSummary.new
	movies = Array.new

        File.readlines($config['plexWatch']['log_file']).each do |line|
            if line.include?("New Movie:")
                second_line = line.slice(/New.*/)
                lines = line.split("New Movie: ")
    
    	        if Time.now.to_i < (Time.parse(lines[0]).to_i + 604800)
    	            movie = lines[1].gsub!(/\[.*/, '').chomp!.rstrip!
		
		    if movie.include?(' ')
		        movie.gsub!(/ /, '+')
		    end
		    
		    begin
        		movie = test.searchMovie(movie)
			movies.push({ 
			    :id       => movie['id'],
			    :title    => movie['title'],
			    :image    => "https://image.tmdb.org/t/p/w154#{movie['poster_path']}",
			    :date     => Time.new(movie['release_date']).year,
			    :tagline  => movie['tagline'],
			    :synopsis => movie['overview'],
			    :runtime  => movie['runtime'],
			    :imdb     => "http://www.imdb.com/title/#{movie['imdb_id']}"
			})
			sleep 0.5
    		    rescue
        	    end
    	        end
            end
        end

	return movies
    end
end

test = ReadLog.new
movies = test.getMovies

        begin
            $config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
        rescue Errno::ENOENT => e
            abort('Configuration file not found.  Exiting...')
        end

template = ERB.new File.new("../etc/email_body.erb").read, nil, "%"
puts template.result(binding)
