# Class that will be used to parse and handle received entity resource payload.
class EtvMediaScraperEntityResource
  attr_reader :name, :url

  def initialize(object)
    @object = object.freeze

    parse_name
    parse_media
  end

  def parse_name
    return unless @object.key?('primaryCategory') && @object['primaryCategory'].key?('name')
    @name = @object['primaryCategory']['name'] unless @object['primaryCategory']['name'].to_s.strip.empty?
  end

  def parse_media
    return unless @object.key?('medias') && !@object['medias'].empty?

    @object['medias'].each do |media|
      @url = 'https:' << media['src']['file']
    end
  end
end
