#!/usr/bin/env ruby
require 'fileutils'

class EtvMediaScraper
    @@config_name = 'config.json'
    @@loot_name = 'loot'

    @tasks = Array.new

    def initialize
        @config_path = File.join(File.dirname(__FILE__), @@config_name)
        @loot_path = File.join(File.dirname(__FILE__), @@loot_name)

        unless File.directory? @loot_path
            FileUtils.mkdir @loot_path
        end
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

