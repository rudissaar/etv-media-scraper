require 'json'

require_relative 'etv_media_scraper_entity'

class EtvMediaScraperConfig
  attr_reader :entities

  def initialize()
    @config_path = File.join(__dir__, '..', 'config.json')
    @entities = []

    unless File.file?(@config_path)
      puts '> Unable to locate config.json file.'
      puts '> Aborting.'
      exit 1
    end

    read_config
  end

  def read_config
    file = File.open(@config_path)
    @data = JSON.parse(File.read(file))

    entities = @data['entities']

    entities.each do |hash|
      create_entity(hash)
    end
  end

  def create_entity(hash)
    entity = EtvMediaScraperEntity.new(hash)
    @entities.push(entity) if entity.valid?
  end

  def downloader_options
    options = {}

    if @data.key?('downloader')
      downloader_options = @data['downloader']

      if downloader_options.key?('use_wget')
        options['use_wget'] = downloader_options['use_wget']
      end
    end

    return options
  end
end
