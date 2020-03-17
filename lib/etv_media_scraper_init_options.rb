# Module that can be prepended/included to class in order to provide class with init_options method.
module EtvMediaScraperInitOptions
  def init_options(options = {})
    options = options.transform_keys(&:to_s)

    options.each do |option, value|
      if @allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end

    options
  end
end
