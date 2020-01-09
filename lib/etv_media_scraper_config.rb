require 'json'

require_relative 'etv_media_scraper_entity'

class EtvMediaScraperConfig
  attr_reader :entities

  def initialize
    @entities = []
    @config_path = File.join(File.dirname(__FILE__), '../config.json')

    unless File.file? @config_path
      puts '> Unable to locate config.json file.'
      puts '> Aborting.'
      exit 1
    end

    parse_config
  end

  def parse_config
    file = File.open(@config_path)
    data = JSON.parse(File.read(file))
    data = data['entities']

    data.each do |hash|
      create_entity(hash)
    end
  end

  def create_entity(hash)
    entity = EtvMediaScraperEntity.new(hash)
    @entities.push(entity) if entity.valid?
  end
end
