#!/usr/bin/ruby
require 'rubygems'
require 'time'
require 'yaml'
require 'erb'
require 'pp'

require_relative 'plex'

# Class for parsing the PlexWatch log for new movies and TV Shows
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class ReadLog
    def initialize
        begin
            $config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
        rescue Errno::ENOENT => e
            abort('Configuration file not found.  Exiting...')
        end
    end
      
    def getMovies
	moviedb = TheMovieDB.new
	plex = Plex.new
	library = plex.get('library/recentlyAdded')
	movies = Array.new

	library['MediaContainer']['Video'].each do | element |
	    if (Time.now.to_i - element['updatedAt'].to_i < 604800)
		plex_movie = plex.get("library/metadata/#{element['ratingKey']}")['MediaContainer']['Video']
    	        movie_id = plex.get("library/metadata/#{element['ratingKey']}")['MediaContainer']['Video']['guid'].gsub(/com.plexapp.agents.themoviedb:\/\//, '').gsub(/\?lang=en/, '')
    	        if !movie_id.include?('local') 
	            begin
       	                movie = moviedb.get("movie/#{movie_id}")
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
    	            rescue
                    end
	        end
            end
    	end

	return movies
    end

    def getTvInfo
	plex = PlexSummary.new
	episodes = Array.new

	File.readlines($config['plexWatch']['log_file']).each do |line|
            if line.include?("New Episode:")
		pp line
	    end
	end
    end
end

test = ReadLog.new
#test.getTvInfo
movies = test.getMovies

template = ERB.new File.new("../etc/email_body.erb").read, nil, "%"
puts template.result(binding)
