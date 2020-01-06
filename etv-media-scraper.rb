#!/usr/bin/env ruby
require 'fileutils'

class EtvMediaScraper
  @tasks = []

  def initialize
    @config_path = File.join(File.dirname(__FILE__), 'config.json')
    @loot_path = File.join(File.dirname(__FILE__), 'loot')

    File.directory? @loot_path unless FileUtils.mkdir @loot_path
  end

  def add_task
  end

  def process_task
  end

  def run
  end
end

scraper = EtvMediaScraper.new
scraper.run
