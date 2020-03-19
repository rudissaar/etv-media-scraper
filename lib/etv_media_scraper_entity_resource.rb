class EtvMediaScraperEntityResource
  attr_reader :name

  def initialize(object)
    @object = object.freeze

    parse_name
  end

  def parse_name
    if @object.key?('primaryCategory') && @object['primaryCategory'].key?('name')
      @name = @object['primaryCategory']['name'] unless @object['primaryCategory']['name'].to_s.strip.empty?
    end
  end
end
