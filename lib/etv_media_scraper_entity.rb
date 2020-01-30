require 'fileutils'

class EtvMediaScraperEntity
  attr_accessor :name
  attr_reader :skip, :category, :etv2, :referer

  def initialize(hash)
    @skip = false
    @name = nil
    @etv2 = false
    @referer = nil

    @skip = hash['skip'] if hash.key?('skip')
    @category = hash['category'].to_i if hash.key?('category')
    @name = hash['name'] if hash.key?('name')
    @etv2 = hash['etv2'] if hash.key?('etv2')

    @rules = {}
    @rules['url_must_exclude'] = []

    if hash.key?('source_rules')
      source_rules = hash['source_rules']
      if source_rules.key?('url_must_exclude')
        source_rules['url_must_exclude'].each do |string_to_exclude|
          @rules['url_must_exclude'].push(string_to_exclude)
        end
      end
    end
  end

  def valid?
    !@skip && @category && @category.is_a?(Integer)
  end

  def complient?(url)
    @rules['url_must_exclude'].each do |string_to_exclude|
      return false if url[string_to_exclude]
    end

    return true
  end

  def move_to_loot(tmp_file_path, loot_path)
    full_loot_path = File.join(loot_path, @name)
    FileUtils.mkdir(full_loot_path) unless File.directory?(full_loot_path)

    loot_file_basename = File.basename(tmp_file_path)
    loot_file_path = File.join(full_loot_path, loot_file_basename)

    FileUtils.mv(tmp_file_path, loot_file_path)
  end
end
