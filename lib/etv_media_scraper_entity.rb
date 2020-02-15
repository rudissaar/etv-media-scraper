require 'fileutils'

# Class that handles task related data and logic.
class EtvMediaScraperEntity
  attr_accessor :name
  attr_reader :skip, :category, :etv2, :referer

  def initialize(hash)
    @hash = hash
    @skip = hash['skip'] if hash.key?('skip')
    @category = hash['category'].to_i if hash.key?('category')
    @name = hash['name'] if hash.key?('name')
    @etv2 = hash['etv2'] if hash.key?('etv2')

    rules
  end

  def rules
    @rules = {}
    @rules[:url_must_exclude] = []

    source_rules
  end

  def source_rules
    return unless @hash.key?('source_rules')
    source_rules = @hash['source_rules']

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

    return true
  end
end
