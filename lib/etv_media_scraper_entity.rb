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
  end

  def valid?
    !@skip && @category && @category.is_a?(Integer)
  end
end
