require 'fileutils'

require_relative 'etv_media_scraper_helper'
require_relative 'etv_media_scraper_init_options'
require_relative 'etv_media_scraper_episode'
require_relative 'etv_media_scraper_output_options'

# Class that holds season related data.
class EtvMediaScraperSeason
  prepend EtvMediaScraperInitOptions
  prepend EtvMediaScraperOutputOptions

  attr_accessor :name, :number
  attr_reader :episode, :signature

  def initialize(options = {})
    @allowed_options = %w[name number episode signature]

    output_options
    init_options(options)
  end

  def create_episode(options = {})
    @episode = EtvMediaScraperEpisode.new(options)
    @episode.season = self

    @episode
  end

  def final_loot_pathname
    parts = []

    unless @name.to_s.strip.empty?
      parts.push(@name)
      parts.push('S' << format('%02d', @number)) if @number
    end

    name = parts.join('.')
    name << '-' << @signature if @signature

    name
  end

  def final_loot_path
    path = ''

    if final_loot_pathname
      path = File.join(@episode.loot_path, final_loot_pathname)
      FileUtils.mkdir(path) unless File.directory?(path)
    else
      path = @episode.loot_path
    end

    path
  end
end
