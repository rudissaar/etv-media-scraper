require 'fileutils'

require_relative 'etv_media_scraper_downloader'

# Class for Episode.
class EtvMediaScraperEpisode
  attr_accessor :name, :url, :season, :number, :verbose

  def initialize(options = {})
    @allowed_options = %w[name url season number verbose]
    @paths = %w[skip tmp loot]
    @verbose = true

    options.each do |option, value|
      if @allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end

    set_and_create_paths
  end

  def set_and_create_paths
    @paths.each do |path|
      joined_path = File.join(__dir__, '..', path)
      instance_variable_set("@#{path}_path", joined_path)
      FileUtils.mkdir(joined_path) unless File.directory?(joined_path)
    end
  end

  def set_skip_file
    @skip_file = File.join(@skip_path, File.basename(@url))
  end

  def set_skip
    if File.file?(@skip_file)
      puts('> Skipping: ' + File.basename(@skip_file)) if @verbose
      @skip = true
    end
  end

  def set_destination
    @destination = File.join(@tmp_path, File.basename(@url))
  end

  def set_final_loot_path
    if @name
      name = @name
      name += '.S' + sprintf('%02d', @season) if @season
      
      @final_loot_path = File.join(@loot_path, name)
      FileUtils.mkdir(@final_loot_path) unless File.directory?(@final_loot_path)
    else
      @final_loot_path = @loot_path
    end
  end

  def set_final_loot_file
    name = File.basename(@url)
    @final_loot_file = File.join(@final_loot_path, name)
  end

  def before_download
    set_skip_file
    set_skip
    return if @skip    

    set_destination
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
    set_final_loot_path
    set_final_loot_file
    move_to_loot
  end

  def move_to_loot
    FileUtils.mv(@destination, @final_loot_file)
  end
end
