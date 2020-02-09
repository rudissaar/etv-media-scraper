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

class EtvMediaScraper
  @@etv_api_url = 'https://etv.err.ee/api/tv/getCategoryPastShows?category='
  @@etv2_api_url = 'https://etv2.err.ee/api/tv/getCategoryPastShows?category='
  @@api_params_ts_string = '&periodStart=0&periodEnd=' + Time.now.to_i.to_s
  @@api_params_string = '&fullData=1'

  def initialize
    @tmp_path = File.join(__dir__, 'tmp')
    @loot_path = File.join(__dir__, 'loot')

    FileUtils.mkdir @tmp_path unless File.directory? @tmp_path
    FileUtils.mkdir @loot_path unless File.directory? @loot_path

    @config = EtvMediaScraperConfig.new
    @entities = @config.entities

    @resouce_url = nil
  end

  def process_entity(entity)
    @resource_url = build_resource_url(entity)
    @episodes = []

    fetch_resources(entity)

    @episodes.each do |episode|
      downloader = EtvMediaScraperDownloader.new(episode.url, @tmp_path, @config.downloader_options)
      downloaded_file = downloader.run
      entity.move_to_loot(downloaded_file, @loot_path, episode) if downloaded_file
    end
  end

  def build_resource_url(entity)
    if entity.etv2
      url = @@etv2_api_url
    else
      url = @@etv_api_url
    end

    url.concat(entity.category.to_s)
    url.concat(@@api_params_string)

    return url
  end

  def fetch_resources(entity)
    uri = URI(@resource_url)
    
    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https',
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      json = JSON.parse(response.body)

      json['data'].each do |obj|
        unless entity.name
          entity.name = obj['primaryCategory']['name']
        end

        episode = EtvMediaScraperEpisode.new

        obj['medias'].each do |media|
          url = 'https:' + media['src']['file']
          if entity.complient?(url)
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
      process_entity(entity)
    end
  end
end

scraper = EtvMediaScraper.new
scraper.run
