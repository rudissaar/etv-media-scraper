require 'fileutils'

require_relative 'etv_media_scraper_global'

# Class that handles task related data and logic.
class EtvMediaScraperEntity
  prepend EtvMediaScraperGlobal

  attr_accessor :name
  attr_reader :skip, :category, :parent_content_id, :etv2, :referer, :ignore_special_episodes

  def initialize(options)
    @options = options

    allowed_options = %w[name skip category parent_content_id etv2 referer ignore_special_episodes]

    options.each do |option, value|
      if allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end

    rules
  end

  def rules
    @rules = {}
    @rules[:url_must_exclude] = []

    source_rules
  end

  def source_rules
    return unless @options.key?('source_rules')
    source_rules = @options['source_rules']

    if source_rules.key?('url_must_exclude')
      source_rules['url_must_exclude'].each do |string_to_exclude|
        @rules[:url_must_exclude].push(string_to_exclude)
      end
    end

    if source_rules.key?('ignore_special_episodes')
      value = source_rules['ignore_special_episodes']
      value = value.to_s == 'true' || value.to_s == '1' ? true : false
      @ignore_special_episodes = value
    end
  end

  def valid?
    return false if @skip

    if $config.mode == 2
      return @parent_content_id && @parent_content_id.is_a?(Integer) ? true : false
    end

    @category && @category.is_a?(Integer)
  end

  def complient?(url)
    @rules[:url_must_exclude].each do |string_to_exclude|
      return false if url[string_to_exclude]
    end

    true
  end
end
