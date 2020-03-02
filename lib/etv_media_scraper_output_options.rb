require_relative 'etv_media_scraper_global'

# Module that can be prepended/included to class in order to set instance variables from output_options config section.
module EtvMediaScraperOutputOptions
  prepend EtvMediaScraperGlobal

  def output_options
    $config.output_options.each do |option, value|
      if @allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end
  end
end
