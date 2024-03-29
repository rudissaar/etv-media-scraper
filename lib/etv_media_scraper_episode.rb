require 'fileutils'
require 'pathname'

require_relative 'etv_media_scraper_downloader'
require_relative 'etv_media_scraper_global'
require_relative 'etv_media_scraper_helper'
require_relative 'etv_media_scraper_init_options'
require_relative 'etv_media_scraper_output_options'
require_relative 'etv_media_scraper_season'

# Class that holds data and logic for media.
class EtvMediaScraperEpisode
  prepend EtvMediaScraperGlobal
  prepend EtvMediaScraperInitOptions
  prepend EtvMediaScraperOutputOptions

  attr_accessor :number, :name, :url, :verbose
  attr_reader :loot_path, :season

  def initialize(options = {})
    @allowed_options = %w[name url number verbose signature episode_names episode_padding]
    @paths = %w[skip tmp loot]
    @episode_names = true
    @episode_padding = 2
    @verbose = true

    output_options
    init_options(options)

    assign_and_create_paths
  end

  def season=(season_instance)
    @season = season_instance if season_instance.is_a?(EtvMediaScraperSeason)
  end

  def source_type
    parts = EtvMediaScraperHelper.filename_parts(@url)
    parts['extension'] == '.m3u8' ? 'WEBRip' : 'WEB'
  end

  def assign_and_create_paths
    @paths.each do |path|
      joined_path = File.join(__dir__, '..', path)
      instance_variable_set("@#{path}_path", joined_path)
      FileUtils.mkdir(joined_path) unless File.directory?(joined_path)
    end
  end

  def skip
    skip_index_array.include?(source_index)
  end

  def destination
    Pathname.new(File.join(@tmp_path, File.basename(@url))).cleanpath.to_s
  end

  def track_label
    parts = []

    parts.push(@season.name) unless @season.name.to_s.strip.empty?

    number_string = ''
    number_string << 'S' << format('%02d', @season.number) unless @season.number.to_s.strip.empty?
    number_string << 'E' << format("%0#{@episode_padding}d", @number) unless @number.to_s.strip.empty?

    parts.push(number_string) unless number_string.empty?
    parts.push(source_type) unless source_type.empty?

    parts.join('.')
  end

  def final_loot_filename
    parts = []
    parts.push(EtvMediaScraperHelper.dotify_string(@name)) if !@name.to_s.strip.empty? && @episode_names
    parts.unshift(track_label) unless track_label.to_s.strip.empty?

    if parts.empty?
      parts.push(File.basename(@url))
    else
      parts.push(File.extname(@url).delete('.'))
    end

    name = parts.join('.')
    name = EtvMediaScraperHelper.add_signature_to_filename(name, @signature) unless @signature.to_s.strip.empty?

    name
  end

  def final_loot_file
    File.join(@season.final_loot_path, final_loot_filename)
  end

  def source_index(filename = nil)
    filename = @url if filename.nil?
    parts = EtvMediaScraperHelper.filename_parts(filename)
    match = parts[:basename].match(/(^\d{4}-\d{6}-\d{4})/)
    index = match ? match.captures.last : nil
    index = parts[:basename].split('_').first if index.nil?
    index
  end

  def skip_index_array
    index_array = Dir.entries(@skip_path)
    index_array.reject { |entry| entry == '.' || entry == '..' }
    index_array.map { |index| source_index(index) }
  end

  def skip_file
    parts = EtvMediaScraperHelper.filename_parts(@url)
    File.join(@skip_path, parts[:filename])
  end

  def before_download
    return if skip
    return unless File.file?(destination)

    puts('> Removing existing file: ' << destination) if @verbose
    File.delete(destination)
  end

  def download
    before_download

    if skip
      puts('> Skipping: ' << File.basename(skip_file)) if @verbose
      return
    end

    downloader = EtvMediaScraperDownloader.new
    downloader.url = @url
    downloader.destination = destination
    downloader.run

    after_download
  end

  def after_download
    FileUtils.touch(skip_file)
    FileUtils.mv(destination, final_loot_file)
  end
end
