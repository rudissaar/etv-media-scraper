require 'json'

require_relative 'etv_media_scraper_entity'

# Class that handles reading configuration file and creating entities/tasks.
class EtvMediaScraperConfig
  attr_reader :mode, :entities

  def initialize
    @config_path = File.join(__dir__, '..', 'config.json')
    @entities = []

    unless File.file?(@config_path)
      puts('> Unable to locate config.json file.')
      puts('> Aborting.')
      exit(1)
    end

    read_config
  end

  def read_config
    file = File.open(@config_path)
    @data = JSON.parse(File.read(file))
    @mode = @data.key?('mode') ? @data['mode'].to_i : 1
  end

  def create_entities
    entities = @data['entities']
    entities.each do |options|
      create_entity(options)
    end
  end

  def create_entity(options)
    entity = EtvMediaScraperEntity.new(options)
    @entities.push(entity) if entity.valid?
  end

  def downloader_options
    options = {}

    return options unless @data.key?('downloader') || @data['downloader'].is_a?(Hash)
    allowed_options = %w[use_wget wget_path]

    @data['downloader'].each do |option, value|
      options[option] = @data['downloader'][option] = value if allowed_options.include?(option)
    end

    options
  end

  def output_options
    options = {}

    return options unless @data.key?('output') || @data['output'].is_a?(Hash)
    allowed_options = %w[signature episode_names episode_padding]

    @data['output'].each do |option, value|
      options[option] = @data['output'][option] = value if allowed_options.include?(option)
    end

    options
  end
end
