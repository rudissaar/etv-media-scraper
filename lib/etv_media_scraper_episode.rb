require_relative 'etv_media_scraper_downloader'

class EtvMediaScraperEpisode
  attr_accessor :url, :season, :number

  @allowed_options = %w[url season number]

  def initialize(options = {})
    options.each do |option, value|
      if @allowed_options.include?(option)
        instance_variable_set("@#{options}") unless value.nil?
      end
    end
  end
end
