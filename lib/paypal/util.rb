module Paypal
  module Util
    def self.deep_symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), memo|
        memo[key.to_sym] = value.is_a?(Hash) ? deep_symbolize_keys(value) : value
      end
    end

    def self.blank?(value)
      value.respond_to?(:empty?) ? value.empty? : !value
    end

    def self.present?(...)
      !blank?(...)
    end

    def self.now
      if Time.respond_to?(:zone)
        Time.zone.now
      else
        Time.now
      end
    end
  end
end
