#!/usr/bin/ruby
require 'rubygems'
require 'time'
require 'yaml'
require 'erb'

require_relative 'plex'
require_relative 'themoviedb'
require_relative 'thetvdb'

# Class for parsing the PlexWatch log for new movies and TV Shows
#
# Author: Brian Stascavage
# Email: brian@stascavage.com
#
class PlexReport
    def initialize
        begin
            $config = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
        rescue Errno::ENOENT => e
            abort('Configuration file not found.  Exiting...')
        end
    end
     
    # Method for retrieving information for all movies for a given period of time. 
    def getMovies
    	moviedb = TheMovieDB.new
	    plex = Plex.new
	    library = plex.get('/library/recentlyAdded')
	    movies = Array.new

	    library['MediaContainer']['Video'].each do | element |
	        if (Time.now.to_i - element['addedAt'].to_i < 604800)
		        plex_movie = plex.get("/library/metadata/#{element['ratingKey']}")['MediaContainer']['Video']
    	        
                # This is some contrivulted logic to strip off the moviedb.org id
                # from the Plex mediadata.  I wish Plex made this information
                # easier to get
                movie_id = plex.get("/library/metadata/#{element['ratingKey']}")['MediaContainer']['Video']['guid'].gsub(/com.plexapp.agents.themoviedb:\/\//, '').gsub(/\?lang=en/, '')
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
	    return movies.sort_by { |hsh| hsh[:title] }
    end

    # Method for getting new TV episodes for a given time period.  
    # This only returns new episodes, not seasons
    def getNewTVEpisodes
        thetvdb = TheTVDB.new
        plex = Plex.new
        library = plex.get('/library/recentlyAdded')
        tv_episodes = Array.new

	    library['MediaContainer']['Directory'].each do | element |
            if element['type'].include?('season')
                if ((Time.now.to_i - element['addedAt'].to_i < 604800) &&
                        (!(Time.now.to_i - element['updatedAt'].to_i < 604800) || 
                        !element.has_key?('updatedAt')))

                    show_episodes = plex.get("/library/metadata/#{element['parentRatingKey']}/allLeaves")

                    # This checks for any shows that are exact one episode large.
                    # This shows don't have an "updatedAt" field yet.
                    if show_episodes['MediaContainer']['size'].to_i == 1
                        begin
                            episode = show_episodes['MediaContainer']['Video']

                            # This is some contrivulted logic to strip off the 
                            # thetvdc.com id
                            # from the Plex mediadata.  I wish Plex made this 
                            # information easier to get
                            show_id = plex.get(episode['parentKey'])['MediaContainer']['Directory']['guid'].gsub(/.*:\/\//, '').gsub(/\/.*/, '')
                            
                            show = thetvdb.get("series/#{show_id}/all/")['Data']['Series']
                            tv_episodes.push({
                                :id             => show_id,
                                :series_name    => show['SeriesName'],
                                :image          => "http://thetvdb.com/banners/#{show['poster']}",
                                :network        => show['Network'],
                                :imdb           => "http://www.imdb.com/title/#{show['IMDB_ID']}",
                                :title          => episode['title'],
                                :episode_number => "S#{episode['parentIndex']} E#{episode['index']}",
                                :synopsis       => episode['summary'],
                                :synopsis       => episode['summary'],
                                :airdate        => episode['originallyAvailableAt']
                            })
                        rescue
                        end
                    else
                        show_episodes['MediaContainer']['Video'].each do | episode |
                            begin
                                if (Time.now.to_i - episode['addedAt'].to_i < 604800) 
                                    # This is some contrivulted logic to strip off 
                                    # the thetvdc.com id
                                    # from the Plex mediadata.  I wish Plex made this
                                    # information easier to get
                                    show_id = plex.get(episode['parentKey'])['MediaContainer']['Directory']['guid'].gsub(/.*:\/\//, '').gsub(/\/.*/, '')

                                    show = thetvdb.get("series/#{show_id}/all/")['Data']['Series']

                                    tv_episodes.push({
                                        :id             => show_id,
                                        :series_name    => show['SeriesName'],
                                        :image          => "http://thetvdb.com/banners/#{show['poster']}",
                                        :network        => show['Network'],
                                        :imdb           => "http://www.imdb.com/title/#{show['IMDB_ID']}",
                                        :title          => episode['title'],
                                        :episode_number => "S#{episode['parentIndex']} E#{episode['index']}",
                                        :synopsis       => episode['summary'],
                                        :synopsis       => episode['summary'],
                                        :airdate        => episode['originallyAvailableAt']
                                    })
                                end
                            rescue
                            end
                        end
                    end
                end
            end
        end 
	    return tv_episodes.sort_by { |hsh| hsh[:series_name] }  
    end

    # Method that returns the metadata for any new seasons added to the Plex.
    # A season is determined by counting all of the "leaves" in Plex and
    # checking that number against the total episodes in a season, according
    # to thetvdb.com
    def getNewTVSeasons
        thetvdb = TheTVDB.new
        plex = Plex.new
        library = plex.get('/library/recentlyAdded')
        tv_episodes = Array.new

        library['MediaContainer']['Directory'].each do | element |
            if ((Time.now.to_i - element['addedAt'].to_i < 604800))

                # This is some contrivulted logic to strip off the
                # thetvdc.com id
                # from the Plex mediadata.  I wish Plex made this
                # information easier to get
                show_id = plex.get(element['parentKey'])['MediaContainer']['Directory']['guid'].gsub(/.*:\/\//, '').gsub(/\/.*/, '').gsub(/\?.*/, '')
                begin
                    show = thetvdb.get("series/#{show_id}/all/")['Data']
                    season_mapping = Hash.new
                    show['Episode'].each do | episode_count |
                        season_mapping[episode_count['SeasonNumber']] = 
                            episode_count['EpisodeNumber']
                    end
                    if season_mapping[element['index']] == element['leafCount']
                        if tv_episodes.detect { |f| f[:id].to_i == show_id.to_i }
                            tv_episodes.each do |x|
                                if x[:id] == show_id
                                    x[:season].push(element['index'])
                                end
                            end
                        else
                            tv_episodes.push({
                                :id             => show_id,
                                :series_name    => show['Series']['SeriesName'],
                                :image          => "http://thetvdb.com/banners/#{show['Series']['poster']}",
                                :season         => [element['index']],
                                :network        => show['Series']['Network'],
                                :imdb           => "http://www.imdb.com/title/#{show['Series']['IMDB_ID']}",
                                :synopsis       => show['Series']['Overview']
                            })
                        end
                    end  
                    rescue
                end                    
            end
        end
        return tv_episodes
    end
end

# Main method that starts the report
def main
    test = PlexReport.new
    new_episodes = test.getNewTVEpisodes
    new_seasons = test.getNewTVSeasons
    movies = test.getMovies

    YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), '../etc/config.yaml') )
    template = ERB.new File.new(File.join(File.expand_path(File.dirname(__FILE__)), "../etc/email_body.erb") ).read, nil, "%"
    puts template.result(binding)
end

main()
