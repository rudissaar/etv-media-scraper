#!/usr/bin/env ruby

require 'fileutils'
require 'json'
require 'net/https'
require 'open-uri'
require 'time'
require 'uri'

require_relative File.join('lib', 'etv_media_scraper_config')
require_relative File.join('lib', 'etv_media_scraper_entity')
require_relative File.join('lib', 'etv_media_scraper_episode')
require_relative File.join('lib', 'etv_media_scraper_downloader')

# Bootstrap class that connects everything together.
class EtvMediaScraper
  def initialize
    @etv_api_url = 'https://etv.err.ee/api/tv/getCategoryPastShows?category='
    @etv2_api_url = 'https://etv2.err.ee/api/tv/getCategoryPastShows?category='
    @api_params_ts_string = '&periodStart=0&periodEnd=' + Time.now.to_i.to_s
    @api_params_string = '&fullData=1'

    @config = EtvMediaScraperConfig.new
    @entities = @config.entities
  end

  def process_entity
    @resource_url = build_resource_url
    @episodes = []

    fetch_resources
    @episodes.each(&:download)
  end

  def build_resource_url
    url = @entity.etv2 ? @etv2_api_url : @etv_api_url
    url.concat(@entity.category.to_s)
    url.concat(@api_params_string)

    url
  end

  def resources_http_options
    uri = URI(@resource_url)
    options = { options: {} }

    options[:uri] = uri
    options[:options][:use_ssl] = uri.scheme == 'https'
    options[:options][:verify_mode] = OpenSSL::SSL::VERIFY_NONE if options[:options][:use_ssl]

    options
  end

  def fetch_resources
    options = resources_http_options

    Net::HTTP.start(options[:uri].host, options[:uri].port, options[:options]) do |http|
      request = Net::HTTP::Get.new(options[:uri].request_uri)

      response = http.request(request)
      json = JSON.parse(response.body)

      json['data'].each do |obj|
        @entity.name = obj['primaryCategory']['name'] unless @entity.name

        episode = EtvMediaScraperEpisode.new

        obj['medias'].each do |media|
          url = 'https:' + media['src']['file']
          if @entity.complient?(url)
            episode.name = @entity.name
            episode.url = url
          end
        end

        next unless episode.url
        episode.season = obj['season'].to_i if obj.key?('season')
        @episodes.push(episode)
      end
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
