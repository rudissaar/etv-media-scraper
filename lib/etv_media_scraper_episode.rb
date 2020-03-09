require 'fileutils'
require 'pathname'

require_relative 'etv_media_scraper_downloader'
require_relative 'etv_media_scraper_global'
require_relative 'etv_media_scraper_helper'
require_relative 'etv_media_scraper_output_options'
require_relative 'etv_media_scraper_season'

# Class that holds data and logic for media.
class EtvMediaScraperEpisode
  prepend EtvMediaScraperGlobal
  prepend EtvMediaScraperOutputOptions

  attr_accessor :number, :name, :url, :verbose
  attr_reader :loot_path

  def initialize(options = {})
    @allowed_options = %w[name url season number verbose signature]
    @paths = %w[skip tmp loot]
    @verbose = true

    output_options
    options.each do |option, value|
      if @allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end

    assign_and_create_paths
  end

  def season=(season_instance)
    @season = season_instance if season_instance.is_a?(EtvMediaScraperSeason)
  end

  def assign_and_create_paths
    @paths.each do |path|
      joined_path = File.join(__dir__, '..', path)
      instance_variable_set("@#{path}_path", joined_path)
      FileUtils.mkdir(joined_path) unless File.directory?(joined_path)
    end
  end

  def assign_skip_files
    @skip_files = skip_files
  end

  def assign_skip
    skip = false

    @skip_files.each do |skip_file|
      skip = true if File.file?(skip_file)
      puts('> Skipping: ' << File.basename(skip_file)) if skip && @verbose
    end

    @skip = skip
  end

  def assign_destination
    @destination = Pathname.new(File.join(@tmp_path, File.basename(@url))).cleanpath.to_s
    return unless File.file?(@destination)
    puts('> Removing existing file: ' << @destination) if @verbose
    File.delete(@destination)
  end

  def assign_track_label
    string = ''

    string << @season.name << '.' unless @season.to_s.strip.empty?
    string << 'S' << format('%02d', @season.number) unless @season.number.to_s.strip.empty?
    string << 'E' << format('%02d', @number) unless @number.to_s.strip.empty?

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
    @final_loot_file = File.join(@season.final_loot_path, @final_loot_filename)
  end

  def skip_files
    parts = EtvMediaScraperHelper.filename_parts(@url)
    numbers = Array(0..9)
    files = [File.join(@skip_path, parts[:filename])]

    match = parts[:basename].match(/ETV(?:1|2)_(\d?)\z/)
    digit = match ? match.captures.last.to_i : nil

    if digit
      numbers.delete(digit)
      duplication = File.join(@skip_path, parts[:basename].delete_suffix('_' << digit.to_s) << parts[:extension])
      files.push(duplication) if File.file?(duplication)
    end

    numbers.each do |number|
      duplication = File.join(@skip_path, parts[:basename] << '_' << number.to_s << parts[:extension])
      files.push(duplication) if File.file?(duplication)
    end

    files
  end

  def before_download
    assign_skip_files
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
    skip_files.each { |skip_file| FileUtils.touch(skip_file) }
    assign_final_loot_file
    move_to_loot
  end

  def move_to_loot
    FileUtils.mv(@destination, @final_loot_file)
  end
end
