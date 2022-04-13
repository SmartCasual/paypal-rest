require "delegate"
require "faraday"
require "faraday/retry"

module Paypal
  class REST
    class Connection < SimpleDelegator
      def initialize(&block)
        connection = Faraday.new(url: config.api_endpoint) do |faraday|
          faraday.request :retry
          faraday.response :logger, logger, bodies: config.log_response_bodies

          block.call(faraday) if Util.present?(block)
        end

        super(connection)
      end

    private

      def config
        @config ||= Paypal::REST.configuration
      end

      def logger
        @logger ||= (config.logger || Logger.new($stdout))
      end
    end
  end
end
