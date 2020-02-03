require 'fileutils'
require 'net/https'
require 'progressbar'
require 'uri'

class EtvMediaScraperDownloader
  @@skip_path = File.join(File.dirname(__FILE__), '../skip')

  def initialize(source_url = nil, destination_path = nil, options = {})
    @source_url = source_url
    @destination_path = destination_path

    options.each do |option, value|
      instance_variable_set("@#{option}", value) unless value.nil?
    end
  end

  def run
    basename = File.basename(@source_url)
    skip_file = File.join(@@skip_path, basename)
    destination_file = File.join(@destination_path, basename)

    if File.file?(skip_file)
      puts('> Skipping: ' + basename)
      return nil
    end

    unless File.file?(destination_file)
      puts('> Downloading: ' + @source_url)
      uri = URI(@source_url)

      response = Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https',
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        progressbar = ProgressBar.create(
          :format => "%a %b\u{15E7}%i %p%% %t",
          :progress_mark => ' ',
          :remainder_mark => "\u{FF65}")

        http.request(request) do |response|
          if response.header['content-length']
            progressbar.total = response.header['content-length'].to_i
          end

          File.open(destination_file, 'wb') do |file|
            response.read_body do |chunk|
              file.write(chunk)
              progressbar.progress += chunk.length
            end
          end
        end
      end
    end

    FileUtils.touch(skip_file)

    return destination_file
  end
end
