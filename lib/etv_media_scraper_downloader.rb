require 'fileutils'
require 'net/https'
require 'uri'

class EtvMediaScraperDownloader
  def initialize(source_url = nil, destination_path = nil)
    @source_url = source_url
    @destination_path = destination_path

    @skip_path = File.join(File.dirname(__FILE__), '../skip')
  end

  def run
    basename = File.basename(@source_url)
    skip_file = File.join(@skip_path, basename)
    destination_file = File.join(@destination_path, basename)

    if File.file?(skip_file)
      puts('> Skipping: ' + basename)
      return
    end

    unless File.file?(destination_file)
      puts('> Downloading: ' + @source_url)
      uri = URI(@source_url)

      response = Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https',
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)

        http.request(request) do |response|
          File.open(destination_file, 'wb') do |file|
            response.read_body do |chunk|
              file.write(chunk)
            end
          end
        end
      end
    end
  end
end
