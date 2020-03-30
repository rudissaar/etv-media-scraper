require 'fileutils'
require 'net/https'
require 'progressbar'
require 'shellwords'
require 'uri'

require_relative 'etv_media_scraper_downloader_options'
require_relative 'etv_media_scraper_helper'

# Class that handles downloading media files.
class EtvMediaScraperDownloader
  prepend EtvMediaScraperDownloaderOptions

  attr_accessor :url, :destination, :verbose

  def initialize
    @allowed_options = %w[use_wget wget_path verbose]
    @verbose = true

    downloader_options
  end

  def wget_command
    wget_path = @wget_path ? @wget_path : 'wget'

    argv = Shellwords.split(wget_path)
    argv << Shellwords.escape(@url)
    argv << Shellwords.split('-O')
    argv << Shellwords.escape(@destination)

    argv.join(' ')
  end

  def run_wget
    command = wget_command
    system(command)
  end

  def progressbar
    @progressbar = ProgressBar.create(
      format: "%a %b\u{15E7}%i %p%% %t",
      progress_mark: ' ',
      remainder_mark: "\u{FF65}"
    )
  end

  def native_http_options
    EtvMediaScraperHelper.http_options(@url)
  end

  def run_native
    options = native_http_options

    Net::HTTP.start(options[:uri].host, options[:uri].port, options[:options]) do |http|
      request = Net::HTTP::Get.new(options[:uri].request_uri)
      progressbar

      http.request(request) do |response|
        @progressbar.total = response.header['content-length'].to_i if response.header['content-length']

        File.open(@destination, 'wb') do |file|
          response.read_body do |chunk|
            file.write(chunk)
            @progressbar.progress += chunk.length
          end
        end
      end
    end
  end

  def run
    puts('> Downloading: ' + @url) if @verbose
    @use_wget ? run_wget : run_native
  end
end
