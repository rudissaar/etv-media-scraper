require 'fileutils'
require 'pathname'

require_relative 'etv_media_scraper_config'
require_relative 'etv_media_scraper_downloader'
require_relative 'etv_media_scraper_helper'
require_relative 'etv_media_scraper_season'

# Class that holds data and logic for media.
class EtvMediaScraperEpisode
  attr_accessor :season, :number, :name, :url, :verbose

  def initialize(options = {})
    @config = EtvMediaScraperConfig.new
    @allowed_options = %w[name url season number verbose signature]
    @paths = %w[skip tmp loot]
    @verbose = true

    config_output_options

    options.each do |option, value|
      if @allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end

    assign_and_create_paths
  end

  def config_output_options
    @config.output_options.each do |option, value|
      if @allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end
  end

  def assign_and_create_paths
    @paths.each do |path|
      joined_path = File.join(__dir__, '..', path)
      instance_variable_set("@#{path}_path", joined_path)
      FileUtils.mkdir(joined_path) unless File.directory?(joined_path)
    end
  end

  def assign_skip_file
    @skip_file = File.join(@skip_path, File.basename(@url))
  end

  def assign_skip
    return unless File.file?(@skip_file)
    puts('> Skipping: ' << File.basename(@skip_file)) if @verbose
    @skip = true
  end

  def assign_destination
    @destination = Pathname.new(File.join(@tmp_path, File.basename(@url))).cleanpath.to_s
    return unless File.file?(@destination)
    puts('> Removing existing file: ' << @destination) if @verbose
    File.delete(@destination)
  end

  def assign_final_loot_pathname
    parts = []

    unless @season.name.to_s.strip.empty?
      parts.push(@season.name)
      parts.push('S' << format('%02d', @season.number)) if @season.number
    end

    name = parts.join('.')

    @final_loot_pathname = name
  end

  def assign_final_loot_path
    assign_final_loot_pathname

    if @final_loot_pathname
      @final_loot_path = File.join(@loot_path, @final_loot_pathname)
      FileUtils.mkdir(@final_loot_path) unless File.directory?(@final_loot_path)
    else
      @final_loot_path = @loot_path
    end
  end

  def assign_track_label
    string = ''

    string << @final_loot_pathname unless @final_loot_pathname.to_s.strip.empty?
    string << 'E' << format('%02d', @number) if @number

    @track_label = string
  end

  def assign_final_loot_filename
    assign_track_label

    parts = []
    parts.push(EtvMediaScraperHelper.dotify_string(@name)) unless @name.to_s.strip.empty?
    parts.unshift(@track_label) unless @track_label.to_s.strip.empty?

    if parts.empty?
      parts.push(File.basename(@url))
    else
      parts.push(File.extname(@url).delete('.'))
    end

    name = parts.join('.')
    name = EtvMediaScraperHelper.add_signature_to_filename(name, @signature) unless @signature.to_s.strip.empty?

    @final_loot_filename = name
  end

  def assign_final_loot_file
    assign_final_loot_filename
    @final_loot_file = File.join(@final_loot_path, @final_loot_filename)
  end

  def before_download
    assign_skip_file
    assign_skip
    return if @skip

    assign_destination
  end

  def download
    before_download

    return if @skip
    downloader = EtvMediaScraperDownloader.new
    downloader.url = @url
    downloader.destination = @destination
    downloader.run

    after_download
  end

  def after_download
    FileUtils.touch(@skip_file)
    assign_final_loot_path
    assign_final_loot_file
    move_to_loot
  end

  def move_to_loot
    FileUtils.mv(@destination, @final_loot_file)
  end
end
