# Class that holds season related data.
class EtvMediaScraperSeason
  attr_accessor :name, :number

  def initialize(options = {})
    @allowed_options = %w[name number episode]

    options.each do |option, value|
      if @allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end
  end

  def final_loot_pathname
    parts = []

    unless @name.to_s.strip.empty?
      parts.push(@name)
      parts.push('S' << format('%02d', @number)) if @number
    end

    parts.join('.')
  end
end
