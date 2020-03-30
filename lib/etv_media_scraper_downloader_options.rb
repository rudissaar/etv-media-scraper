require_relative 'etv_media_scraper_global'

# Module that can be added to class in order to set instance variables from downloader_options config section.
module EtvMediaScraperDownloaderOptions
  prepend EtvMediaScraperGlobal

  def downloader_options
    $config.downloader_options.each do |option, value|
      if @allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end
  end
end
