require "paypal/util"

RSpec.describe Paypal::Util do
  describe ".deep_symbolize_keys" do
    subject(:deep_symbolize_keys) { described_class.deep_symbolize_keys(hash) }

    let(:hash) do
      {
        "key" => {
          "nested_key" => "value",
        },
      }
    end

    it "symbolizes keys" do
      expect(deep_symbolize_keys).to eq(
        key: {
          nested_key: "value",
        },
      )
    end
  end

  describe ".blank?" do
    subject(:blank?) { described_class.blank?(value) }

    context "with a value that responds to empty?" do
      let(:value) { instance_double("Value", empty?: value_empty?) }

      context "with an empty value" do
        let(:value_empty?) { true }

        it { is_expected.to be_truthy }
      end

      context "with a non-empty value" do
        let(:value_empty?) { false }

        it { is_expected.to be_falsey }
      end
    end

    context "with a value that does not respond to empty?" do
      let(:value) { "value" }

      it { is_expected.to be_falsey }
    end
  end
end
