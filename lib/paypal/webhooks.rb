require_relative "util"

module Paypal
  module Webhooks
    class << self
      def configure(&block)
        block.call(configuration)
      end

      def configuration
        @configuration ||= WebhooksConfiguration.new
      end

      def clear_configuration
        @configuration = nil
      end
    end
  end

  WebhooksConfiguration = Struct.new("WebhooksConfiguration", :logger, :webhook_id)
end

require_relative "webhooks/event"
