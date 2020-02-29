require_relative 'etv_media_scraper_config'

# Module that ensures that globals are set.
module EtvMediaScraperGlobal
  $config ||= EtvMediaScraperConfig.new unless $config
end
