#!/usr/bin/env ruby

require 'fileutils'
require 'json'
require 'net/https'

require_relative File.join('lib', 'etv_media_scraper_constants')
require_relative File.join('lib', 'etv_media_scraper_entity')
require_relative File.join('lib', 'etv_media_scraper_episode')
require_relative File.join('lib', 'etv_media_scraper_global')
require_relative File.join('lib', 'etv_media_scraper_helper')
require_relative File.join('lib', 'etv_media_scraper_season')

# Bootstrap class that connects everything together.
class EtvMediaScraper
  prepend EtvMediaScraperGlobal

  def initialize
    assign_selector_param
    assign_selector_key

    $config.create_entities
    @entities = $config.entities
  end

  def assign_selector_param
    @selector_param = $config.mode == 2 ? 'parentContentId=' : 'category='
  end

  def assign_selector_key
    @selector_key = $config.mode == 2 ? 'parent_content_id' : 'category'
  end

  def process_entity
    @resource_url = build_resource_url
    @episodes = []

    fetch_resource
    @episodes.each(&:download)
  end

  def build_resource_url
    url = @entity.etv2 ? EtvMediaScraperConstants::ETV2_API_URL.dup : EtvMediaScraperConstants::ETV_API_URL.dup
    url << @selector_param
    url << @entity.instance_variable_get("@#{@selector_key}").to_s
    url << EtvMediaScraperConstants::API_PARAMS_STRING

    url
  end

  def parse_resource
    @resource.each do |obj|
      @entity.name = obj['primaryCategory']['name'] unless @entity.name
      episode_options = {}

      obj['medias'].each do |media|
        url = 'https:' << media['src']['file']
        episode_options['url'] = url if @entity.complient?(url)
      end

      next unless episode_options['url']

      episode_options['number'] = EtvMediaScraperHelper.parse_episode_number(obj['shortNumberInfo'])
      episode_options['name'] = obj['progTitle']
      episode_options['signature'] = @entity.signature if @entity.signature

      season = @entity.create_season({ 'number' => obj['season'].to_i })
      episode = EtvMediaScraperEpisode.new(episode_options)

      season.episode = episode
      episode.season = season

      next if @entity.ignore_special_episodes && (episode.number.to_i.zero? || season.number.to_i.zero?)
      @episodes.push(episode)
    end
  end

  def fetch_resource
    options = EtvMediaScraperHelper.http_options(@resource_url)

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
