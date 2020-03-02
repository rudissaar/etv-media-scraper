require 'fileutils'

require_relative 'etv_media_scraper_helper'
require_relative 'etv_media_scraper_output_options'

# Class that holds season related data.
class EtvMediaScraperSeason
  prepend EtvMediaScraperOutputOptions

  attr_accessor :name, :number
  attr_reader :episode

  def initialize(options = {})
    @allowed_options = %w[name number episode signature]

    output_options
    options.each do |option, value|
      if @allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end
  end

  def episode=(episode_instance)
    @episode = episode_instance if episode_instance.is_a?(EtvMediaScraperEpisode)
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
