#!/usr/bin/env ruby

require 'fileutils'

require_relative 'lib/etv_media_scraper_config'

class EtvMediaScraper
  def initialize
    @tmp_path = File.join(File.dirname(__FILE__), 'tmp')
    @loot_path = File.join(File.dirname(__FILE__), 'loot')

    FileUtils.mkdir @tmp_path unless File.directory? @tmp_path
    FileUtils.mkdir @loot_path unless File.directory? @loot_path

    @config = EtvMediaScraperConfig.new
    @entities = @config.entities
  end

  def add_task
  end

  def process_task
  end

  def run
    @entities.each do |num|
      puts num.category
    end
  end
end

scraper = EtvMediaScraper.new
scraper.run
