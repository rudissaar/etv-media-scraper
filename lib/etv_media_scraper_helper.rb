require 'uri'
require 'openssl'

# Class that provides shared helper functions.
class EtvMediaScraperHelper
  def self.http_options(url)
    uri = URI(url)
    options = { options: {} }

    options[:uri] = uri
    options[:options][:use_ssl] = uri.scheme == 'https'
    options[:options][:verify_mode] = OpenSSL::SSL::VERIFY_NONE if options[:options][:use_ssl]

    options
  end
end
