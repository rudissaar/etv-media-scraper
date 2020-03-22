require 'openssl'
require 'uri'

# Module that provides shared helper functions.
module EtvMediaScraperHelper
  def self.http_options(url)
    uri = URI(url)
    options = { options: {} }

    options[:uri] = uri
    options[:options][:use_ssl] = uri.scheme == 'https'
    options[:options][:verify_mode] = OpenSSL::SSL::VERIFY_NONE if options[:options][:use_ssl]

    options
  end

  def self.dotify_string(string)
    string.tr!(',.!:@', '')
    string.tr!(' ', '.')

    string
  end

  def self.filename_parts(filename)
    parts = {}

    parts[:filename] = File.basename(filename)
    parts[:directory] = File.dirname(filename)
    parts[:extension] = File.extname(filename)
    parts[:basename] = File.basename(filename, parts[:extension])

    parts
  end

  def self.add_signature_to_filename(filename, signature)
    parts = filename_parts(filename)
    name = parts[:basename] << '-' << signature << parts[:extension]

    File.join(parts[:directory], name)
  end
end
