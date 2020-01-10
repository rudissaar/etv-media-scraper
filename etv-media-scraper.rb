#!/usr/bin/env ruby

require 'fileutils'
require 'json'
require 'net/https'
require 'time'
require 'uri'

require_relative 'lib/etv_media_scraper_config'

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
  end

  def process_entity(entity)
    url = build_resource_url(entity)
    puts url
  end

  def build_resource_url(entity)
    if entity.etv2
      url = @@etv2_api_url
    else
      url = @@etv_api_url
    end

    url.concat(entity.category.to_s)
    url.concat(@@api_params_string)

    url
  end

  def run
    @entities.each do |entity|
      process_entity(entity)
    end
  end
end

scraper = EtvMediaScraper.new
scraper.run
