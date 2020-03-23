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

    return options unless @data.key?('downloader')
    downloader_options = @data['downloader']
    options['use_wget'] = downloader_options['use_wget'] if downloader_options.key?('use_wget')

    options
  end

  def output_options
    options = {}

    return options unless @data.key?('output')

    options['signature'] = @data['output']['signature'] if @data['output'].key?('signature')
    options['episode_padding'] = @data['output']['episode_padding'].to_i if @data['output'].key?('episode_padding')

    options
  end
end
