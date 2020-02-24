require 'openssl'
require 'uri'

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

  def self.parse_episode_number(heading)
    match = heading.to_s.match(/(?:O|Osa):\s(\d+)/)
    match ? match.captures.last.to_i : nil
  end

  def self.dotify_string(string)
    string.tr!(',.!:@', '')
    string.tr!(' ', '.')

    string
  end

  def self.add_signature_to_filename(filename, signature)
    directory = File.dirname(filename)
    extension = File.extname(filename)
    basename = File.basename(filename, extension)

    name = basename << '-' << signature << extension
    File.join(directory, name)
  end
end
