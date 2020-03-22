require_relative 'etv_media_scraper_helper'

# Class that will be used to parse and handle received entity resource payload.
class EtvMediaScraperEntityResource
  attr_reader :name, :url, :episode_number

  def initialize(object)
    @object = object.freeze

    parse_name
    parse_media
    parse_episode_number
  end

  def parse_name
    return unless @object.key?('primaryCategory') && @object['primaryCategory'].key?('name')
    @name = @object['primaryCategory']['name'] unless @object['primaryCategory']['name'].to_s.strip.empty?
  end

  def parse_media
    return unless @object.key?('medias') && !@object['medias'].empty?

    @object['medias'].each do |media|
      @url = 'https:' << media['src']['file']
    end
  end

  def parse_episode_number
    return unless @object.key?('shortNumberInfo') && !@object['shortNumberInfo'].empty?

    match = @object['shortNumberInfo'].to_s.match(/(?:O|Osa):\s(\d+)/)
    @episode_number = match.captures.last.to_i if match
  end
end
