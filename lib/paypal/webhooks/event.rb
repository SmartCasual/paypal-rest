require_relative "x509_certificate"

module Paypal
  module Webhooks
    class Event # rubocop:disable Metrics/ClassLength
      VALID_PAYPAL_CERT_CN = "messageverificationcerts.paypal.com".freeze
      VALID_PAYPAL_CERT_HOST = "api.paypal.com".freeze

      class << self
        def cert_cache
          @cert_cache ||= {}
        end

        def clear_cert_cache
          @cert_cache = nil
        end
      end

      def initialize(params:, request:)
        @request = request
        @body = request.body&.read
        @params = params
      end

      def verify!
        raise EventVerificationFailed unless verify
      end

      def verify
        verify_cert_url && verify_cert && verify_signature
      end

      def type
        @params[:event_type]
      end

      def data
        @data ||= Util.deep_symbolize_keys(@params)[:resource] || {}
      end

    private

      def verify_signature
        cert.verify(
          algorithm:,
          signature:,
          fingerprint:,
        ).tap do |result|
          logger.debug("Bad signature") unless result
        end
      end

      def verify_cert
        verify_common_name && verify_date
      end

      def verify_common_name
        (cert.common_name == VALID_PAYPAL_CERT_CN).tap do |result|
          unless result
            logger.debug {
              "Incorrect common name #{cert.common_name} (expected #{VALID_PAYPAL_CERT_CN})"
            }
          end
        end
      end

      def verify_date
        cert.in_date?.tap do |result|
          logger.debug("Not in date") unless result
        end
      end

      def verify_cert_url
        return false if Util.blank?(cert_url)

        verify_cert_url_scheme && verify_cert_url_host
      end

      def verify_cert_url_scheme
        (cert_url.scheme == "https").tap do |result|
          logger.debug { "#{cert_url.scheme} is not HTTPS" } unless result
        end
      end

      def verify_cert_url_host
        (cert_url.host == VALID_PAYPAL_CERT_HOST).tap do |result|
          unless result
            logger.debug {
              "Incorrect cert URL host #{cert_url.host} (expected #{VALID_PAYPAL_CERT_HOST})"
            }
          end
        end
      end

      def algorithm
        case (algo = get_header("HTTP_PAYPAL_AUTH_ALGO"))
        when "SHA256withRSA" then "SHA256"
        else
          algo
        end
      end

      def signature
        get_header("HTTP_PAYPALAUTH_SIGNATURE")
      end

      def cert_url
        @cert_url ||= URI.parse(get_header("HTTP_PAYPAL_CERT_URL")) if has_header?("HTTP_PAYPAL_CERT_URL")
      end

      def cert
        self.class.cert_cache[cert_url.to_s] ||= X509Certificate.new(cert_url.open.read)
      end

      # https://developer.paypal.com/api/rest/webhooks/#link-eventheadervalidation
      def fingerprint
        [
          get_header("HTTP_PAYPAL_TRANSMISSION_ID"),
          get_header("HTTP_PAYPAL_TRANSMISSION_TIME"),
          config.webhook_id,
          Zlib.crc32(@body),
        ].join("|")
      end

      def config
        @config ||= Paypal::Webhooks.configuration
      end

      def logger
        @logger ||= (config.logger || Logger.new($stdout))
      end

      def get_header(...)
        @request.get_header(...)
      end

      def has_header?(...) # rubocop:disable Naming/PredicateName
        @request.has_header?(...)
      end
    end

    class EventVerificationFailed < StandardError; end
  end
end
