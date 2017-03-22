module CarrierwaveAttachmentscanner
  module Generators
    class ConfigGenerator < ::Rails::Generators::Base
      DEFAULT_URL = "ENV['ATTACHMENT_SCANNER_URL']"
      DEFAULT_API_TOKEN = "ENV['ATTACHMENT_SCANNER_API_TOKEN']"

      desc 'Creates an initializer at config/initializers/carrierwave_attachmentscanner.rb'
      argument :cluster_url, type: :string, default: DEFAULT_URL
      argument :api_token, type: :string, default: DEFAULT_API_TOKEN

      def self.source_root
        File.expand_path("../templates", __FILE__)
      end

      def create_config_file
        template(
          'config.rb.erb',
          File.join('config', 'initializers', 'carrierwave_attachmentscanner.rb')
        )
      end
    end
  end
end
