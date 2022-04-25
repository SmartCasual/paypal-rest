require_relative "connection"

module Paypal
  class REST
    class BearerToken
      def expired?
        return false if expires_at.nil?

        Util.now > (expires_at - 60)
      end

      def to_s
        token
      end

    private

      def token
        Util.deep_symbolize_keys(response)[:access_token]
      end

      def expires_at
        if (expires_in = response[:expires_in])
          Util.now + expires_in.to_i
        end
      end

      def response
        @response ||= connection.post("/v1/oauth2/token", grant_type: "client_credentials").body.tap do |body|
          body = Util.deep_symbolize_keys(body)

          raise body[:message] if body[:name] == "Bad Request"
          raise body[:error_description] if body.has_key?(:error_description)
        end
      end

      def connection
        @connection ||= Connection.new do |faraday|
          faraday.request :authorization, :basic, config.client_id, config.client_secret

          faraday.request :url_encoded
          faraday.response :json
        end
      end

      def config
        Paypal::REST.configuration
      end
    end
  end
end
