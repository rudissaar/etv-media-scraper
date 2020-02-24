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
end
