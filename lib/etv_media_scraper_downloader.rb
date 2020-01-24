require 'fileutils'
require 'net/https'
require 'uri'

class EtvMediaScraperDownloader
  def initialize(source_url = nil, destination_path = nil)
    @source_url = source_url
    @destination_path = destination_path
  end

  def run
    destination_file = File.join(@destination_path, File.basename(@source_url))

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
