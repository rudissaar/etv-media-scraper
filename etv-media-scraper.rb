#!/usr/bin/env ruby

require 'fileutils'
require 'json'
require 'net/https'
require 'open-uri'
require 'time'
require 'uri'

require_relative 'lib/etv_media_scraper_config'
require_relative 'lib/etv_media_scraper_entity'

class EtvMediaScraper
  @@etv_api_url = 'https://etv.err.ee/api/tv/getCategoryPastShows?category='
  @@etv2_api_url = 'https://etv2.err.ee/api/tv/getCategoryPastShows?category='
  @@api_params_ts_string = '&periodStart=0&periodEnd=' + Time.now.to_i.to_s
  @@api_params_string = '&fullData=1'

  def initialize
    @tmp_path = File.join(File.dirname(__FILE__), 'tmp')
    @loot_path = File.join(File.dirname(__FILE__), 'loot')

    FileUtils.mkdir @tmp_path unless File.directory? @tmp_path
    FileUtils.mkdir @loot_path unless File.directory? @loot_path

    @config = EtvMediaScraperConfig.new
    @entities = @config.entities

    @resouce_url = nil
  end

  def process_entity(entity)
    @resource_url = build_resource_url(entity)
    @sources = []

    fetch_resources(entity)

    @entity_path = File.join(@loot_path, entity.name)
    FileUtils.mkdir @entity_path unless File.directory? @entity_path

    @sources.each do |source|
      download_source(source)
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
        obj['medias'].each do |media|
          url = 'https:' + media['src']['file']
          if entity.complient?(url)
            file_size = response.to_hash['content-length']
            filesize = file_size.first if file_size.kind_of?(Array)
            @sources.push({:url => url, :file_size => file_size.to_i})
          end
        end
      end
    end
  end

  def download_source(source)
    destination_file_path = File.join(@entity_path, File.basename(source[:url]))

    unless File.file?(destination_file_path)
      puts('> Downloading: ' + source[:url])

      File.open(destination_file_path, 'wb') do |file|
        file.write open(source[:url]).read
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
