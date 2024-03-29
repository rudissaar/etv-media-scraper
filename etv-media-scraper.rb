#!/usr/bin/env ruby

require 'fileutils'
require 'json'
require 'net/https'
require 'time'

require_relative File.join('lib', 'etv_media_scraper_constants')
require_relative File.join('lib', 'etv_media_scraper_entity')
require_relative File.join('lib', 'etv_media_scraper_entity_resource')
require_relative File.join('lib', 'etv_media_scraper_global')
require_relative File.join('lib', 'etv_media_scraper_helper')

# Bootstrap class that connects everything together.
class EtvMediaScraper
  prepend EtvMediaScraperGlobal

  def initialize
    $config.create_entities
    @entities = $config.entities
  end

  def selector_param
    $config.mode == 2 ? 'parentContentId=' : 'category='
  end

  def selector_key
    $config.mode == 2 ? 'parent_content_id' : 'category'
  end

  def process_entity
    @episodes = []
    fetch_resource
    @episodes.each(&:download)
  end

  def resource_url
    url = @entity.etv2 ? EtvMediaScraperConstants::ETV2_API_URL.dup : EtvMediaScraperConstants::ETV_API_URL.dup
    url << selector_param
    url << @entity.instance_variable_get("@#{selector_key}").to_s
    url << EtvMediaScraperConstants::API_PARAMS_TS_STRING << Time.new.to_i.to_s
    url << EtvMediaScraperConstants::API_PARAMS_STRING
    url
  end

  def parse_resource
    @resource.each do |object|
      entity_resource = EtvMediaScraperEntityResource.new(object)
      @entity.name = entity_resource.name unless @entity.name

      episode_options = entity_resource.episode_options(@entity)
      next unless episode_options['url']

      season = @entity.create_season(number: entity_resource.season_number)
      episode = season.create_episode(episode_options)

      next if @entity.ignore_special_episodes && (episode.number.to_i.zero? || season.number.to_i.zero?)
      @episodes.push(episode)
    end
  end

  def fetch_resource
    options = EtvMediaScraperHelper.http_options(resource_url)

    Net::HTTP.start(options[:uri].host, options[:uri].port, options[:options]) do |http|
      request = Net::HTTP::Get.new(options[:uri].request_uri)
      response = http.request(request)

      json = JSON.parse(response.body)
      @resource = json['data']
      parse_resource
    end
  end

  def run
    @entities.each do |entity|
      @entity = entity
      process_entity
    end
  end
end

scraper = EtvMediaScraper.new
scraper.run
