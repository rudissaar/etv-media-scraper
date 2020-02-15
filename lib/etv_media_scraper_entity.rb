require 'fileutils'

# Class that handles task related data and logic.
class EtvMediaScraperEntity
  attr_accessor :name
  attr_reader :skip, :category, :etv2, :referer

  def initialize(options)
    @options = options
    allowed_options = %w[name skip category etv2 referer]

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
  end

  def valid?
    !@skip && @category && @category.is_a?(Integer)
  end

  def complient?(url)
    @rules[:url_must_exclude].each do |string_to_exclude|
      return false if url[string_to_exclude]
    end

    true
  end
end
