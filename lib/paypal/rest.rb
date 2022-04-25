require "English"

require_relative "util"
require_relative "rest/bearer_token"
require_relative "rest/connection"

module Paypal
  class REST
    class << self
      def configure(&block)
        block.call(configuration)
      end

      def configuration
        @configuration ||= RESTConfiguration.new
      end

      def clear_configuration
        @configuration = nil
      end

      def create_order(full_response: false, **params)
        if full_response
          post("/v2/checkout/orders", params:, headers: {
            Prefer: "return=representation",
          }) # rubocop:disable Style/TrailingCommaInArguments, Layout/MultilineMethodCallBraceLayout
        else
          post("/v2/checkout/orders", params:)[:id]
        end
      end

      def capture_payment_for_order(order_id, full_response: false)
        if full_response
          post("/v2/checkout/orders/#{order_id}/capture", headers: {
            Prefer: "return=representation",
          }) # rubocop:disable Style/TrailingCommaInArguments, Layout/MultilineMethodCallBraceLayout
        else
          post("/v2/checkout/orders/#{order_id}/capture")
        end
      end

      def reset_connection
        @connection = nil
        @bearer_token = nil
      end

    private

      def post(path, params: {}, headers: {})
        reset_connection if @bearer_token&.expired?

        response = connection.post(path, params, headers).body

        response = JSON.parse(response) if response.is_a?(String)
        response = Util.deep_symbolize_keys(response)

        raise response[:error_description] if response.has_key?(:error_description)

        response
      rescue JSON::ParserError, Faraday::ClientError => e
        Rails.logger.error(["#{self.class} - #{e.class}: #{e.message}", e.backtrace].join($INPUT_RECORD_SEPARATOR))
        head :unprocessable_entity
      end

      def connection
        @connection ||= Connection.new do |faraday|
          faraday.request :json
          faraday.response :json

          faraday.request :authorization, "Bearer", bearer_token
        end
      end

      def bearer_token
        return @bearer_token if @bearer_token && !@bearer_token.expired?

        @bearer_token = BearerToken.new
      end
    end
  end

  RESTConfiguration = Struct.new("RESTConfiguration",
    :api_endpoint,
    :client_id,
    :client_secret,
    :log_response_bodies,
    :logger,
  )
end
