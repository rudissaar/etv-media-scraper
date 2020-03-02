#!/usr/bin/env ruby

require 'fileutils'
require 'json'
require 'net/https'
require 'time'

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

    @etv_api_url = 'https://etv.err.ee/api/tv/getCategoryPastShows?' << @selector_param
    @etv2_api_url = 'https://etv2.err.ee/api/tv/getCategoryPastShows?' << @selector_param
    @api_params_ts_string = '&periodStart=0&periodEnd=' + Time.now.to_i.to_s
    @api_params_string = '&fullData=1'

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
    url = @entity.etv2 ? @etv2_api_url : @etv_api_url
    url << @entity.instance_variable_get("@#{@selector_key}").to_s
    url << @api_params_string

    url
  end

  def resource_http_options
    EtvMediaScraperHelper.http_options(@resource_url)
  end

  def parse_resource
    @resource.each do |obj|
      @entity.name = obj['primaryCategory']['name'] unless @entity.name

      episode = EtvMediaScraperEpisode.new

      obj['medias'].each do |media|
        url = 'https:' << media['src']['file']
        episode.url = url if @entity.complient?(url)
      end

      next unless episode.url

      season = EtvMediaScraperSeason.new
      season.name = @entity.name
      season.number = obj['season'].to_i
      season.episode = episode

      episode.number = EtvMediaScraperHelper.parse_episode_number(obj['shortNumberInfo'])
      episode.name = obj['progTitle']
      episode.season = season

      next if @entity.ignore_special_episodes && (episode.number.to_i.zero? || season.number.to_i.zero?)
      @episodes.push(episode)
    end
  end

  def fetch_resource
    options = resource_http_options

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
