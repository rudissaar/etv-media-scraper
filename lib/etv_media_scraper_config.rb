require 'json'

require_relative 'etv_media_scraper_entity'

class EtvMediaScraperConfig
  attr_reader :downloader_options, :entities

  def initialize
    @downloader_options = {}
    @entities = []
    @config_path = File.join(File.dirname(__FILE__), '../config.json')

    unless File.file? @config_path
      puts '> Unable to locate config.json file.'
      puts '> Aborting.'
      exit 1
    end

    default_downloader_options
    parse_config
  end

  def default_downloader_options
    @downloader_options['use_wget'] = false
  end

  def parse_config
    file = File.open(@config_path)
    data = JSON.parse(File.read(file))

    if data.key?('downloader')
      downloader_options = data['downloader']
      if downloader_options.key?('use_wget')
        @downloader_options['use_wget'] = downloader_options['use_wget']
      end
    end

    entities = data['entities']

    entities.each do |hash|
      create_entity(hash)
    end
  end

  def create_entity(hash)
    entity = EtvMediaScraperEntity.new(hash)
    @entities.push(entity) if entity.valid?
  end
end
