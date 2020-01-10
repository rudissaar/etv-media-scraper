class EtvMediaScraperEntity
  attr_accessor :name
  attr_reader :category, :etv2, :referer

  def initialize(hash)
    @name = nil
    @etv2 = false
    @referer = nil

    @category = hash['category'].to_i if hash.key?('category')
    @name = hash['name'] if hash.key?('name')
    @etv2 = hash['etv2'] if hash.key?('etv2')
  end

  def valid?
    @category && @category.is_a?(Integer)
  end
end
