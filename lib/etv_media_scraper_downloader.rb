require 'fileutils'
require 'net/https'
require 'progressbar'
require 'uri'

require_relative 'etv_media_scraper_config'

class EtvMediaScraperDownloader
  attr_accessor :url, :destination

  def initialize
    allowed_options = %w[use_wget]
    config = EtvMediaScraperConfig.new

    config.downloader_options.each do |option, value|
      if allowed_options.include?(option)
        instance_variable_set("@#{option}", value) unless value.nil?
      end
    end
  end

  def run_wget
    system("wget #{@url} -O #{@destination}")
  end

  def run_native
    uri = URI(@url)

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

        File.open(@destination, 'wb') do |file|
          response.read_body do |chunk|
            file.write(chunk)
            progressbar.progress += chunk.length
          end
        end
      end
    end
  end

  def run
    puts('> Downloading: ' + @url)
    @use_wget ? run_wget : run_native
  end
end
