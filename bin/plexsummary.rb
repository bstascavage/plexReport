#!/usr/bin/ruby
require 'rubygems'
require 'json'

require_relative 'themoviedb'

class PlexSummary
    def initialize
        $movies = TheMovieDB.new
    end

    def searchMovie(title)
        movie = $movies.get("search/movie","search_type=ngram&query=#{title}")
	return $movies.get("movie/#{movie['results'][0]['id']}")
    end
end
