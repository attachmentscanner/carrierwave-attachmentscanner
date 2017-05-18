require 'faraday'
require 'faraday_middleware'
require 'carrierwave/attachmentscanner/version'

module CarrierWave
  module AttachmentScanner
    Config = Struct.new(:url, :api_token, :enabled, :logger, :timeout)
                   .new(ENV['ATTACHMENT_SCANNER_URL'], ENV['ATTACHMENT_SCANNER_API_TOKEN'],
                     true, Logger.new(STDOUT), 60)

    DISABLED_WARNING = "[CarrierWave::AttachmentScanner] Disabled".freeze

    class AttachmentScannerError < CarrierWave::IntegrityError
      attr_accessor :status
      attr_accessor :matches
    end

    def self.included(base)
      if Config.enabled
        raise ArgumentError, "AttachmentScanner API Token is required" unless Config.api_token
        raise ArgumentError, "AttachmentScanner URL is required" unless Config.url
      end

      base.before :cache, :scan_file!
    end

    def self.configure
      raise ArgumentError, "Block must be specified for configure" unless block_given?

      yield(Config)
    end

    def scan_file!(new_file)
      return Config.logger.warn(DISABLED_WARNING) unless Config.enabled

      result = send_to_scanner(new_file)
      scan_result_allowed?(result)
    end

    def scan_result_allowed?(result)
      Config.logger.info("[CarrierWave::AttachmentScanner] status: #{result['status']}")
      return true unless blocked_scan_statuses.include?(result['status'])

      Config.logger.warn("[CarrierWave::AttachmentScanner] matched: #{result['matches']}")

      error = AttachmentScannerError.new(scan_error_message(result))
      error.status = result['status']
      error.matches = result['matches']
      raise error
    end

    def blocked_scan_statuses
      %w(found)
    end

    # This can be overridden in order to change the message
    def scan_error_message(_result)
      "AttachmentScanner prevented this upload"
    end

    protected

    def send_to_scanner(new_file)
      # Needed to support the case that a StringIO is being passed.
      # Passes the root StringIO to Faraday::UploadIO unless we think this is a
      # file (i.e. has path) in which case we pass the file.
      # We can't pass the SanitizedFile as it implements read without arguments.
      root_file = new_file
      root_file = root_file.file while root_file.is_a?(CarrierWave::SanitizedFile)
      file_or_path = root_file.respond_to?(:path) ? new_file.path : root_file

      Config.logger.info("[CarrierWave::AttachmentScanner] scanning #{new_file.filename}")
      upload = Faraday::UploadIO.new(file_or_path, new_file.content_type, new_file.filename)
      response = scan_connection.post('/requests', file: upload)
      response.body
    end

    def scan_connection
      Faraday.new(Config.url) do |f|
        f.options[:open_timeout] = Config.timeout
        f.options[:timeout] = Config.timeout
        f.request :multipart
        f.request :url_encoded
        f.authorization :Bearer, Config.api_token
        f.response :json
        f.response :raise_error
        f.adapter :net_http
      end
    end
  end
end
