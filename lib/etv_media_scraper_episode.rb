require 'fileutils'
require 'pathname'

require_relative 'etv_media_scraper_downloader'

# Class that holds data and logic for media.
class EtvMediaScraperEpisode
  attr_accessor :entity_name, :name, :url, :verbose
  attr_reader :season, :number

  def initialize(options = {})
    @paths = %w[skip tmp loot]
    @verbose = true

    allowed_options = %w[entity_name name url season number verbose]

    options.each do |option, value|
      if allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end

    assign_and_create_paths
  end

  def season=(value)
    @season = value.to_i
  end

  def number=(value)
    @number = value.to_i
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
    puts('> Skipping: ' + File.basename(@skip_file)) if @verbose
    @skip = true
  end

  def assign_destination
    @destination = Pathname.new(File.join(@tmp_path, File.basename(@url))).cleanpath.to_s
    return unless File.file?(@destination)
    puts('> Removing existing file: ' + @destination) if @verbose
    File.delete(@destination)
  end

  def assign_final_loot_path
    if @entity_name
      name = @entity_name
      name += '.S' + format('%02d', @season) if @season

      @final_loot_path = File.join(@loot_path, name)
      FileUtils.mkdir(@final_loot_path) unless File.directory?(@final_loot_path)
    else
      @final_loot_path = @loot_path
    end
  end

  def assign_final_loot_file
    name = File.basename(@url)
    @final_loot_file = File.join(@final_loot_path, name)
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
