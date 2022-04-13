require "paypal/webhooks"

RSpec.describe Paypal::Webhooks::X509Certificate do
  subject(:certificate) { described_class.new(data) }

  let(:data) do
    # Expires Aug 21 05:26:54 2017 GMT
    <<~TEST_CERT
      -----BEGIN CERTIFICATE-----
      MIICEjCCAXsCAg36MA0GCSqGSIb3DQEBBQUAMIGbMQswCQYDVQQGEwJKUDEOMAwG
      A1UECBMFVG9reW8xEDAOBgNVBAcTB0NodW8ta3UxETAPBgNVBAoTCEZyYW5rNERE
      MRgwFgYDVQQLEw9XZWJDZXJ0IFN1cHBvcnQxGDAWBgNVBAMTD0ZyYW5rNEREIFdl
      YiBDQTEjMCEGCSqGSIb3DQEJARYUc3VwcG9ydEBmcmFuazRkZC5jb20wHhcNMTIw
      ODIyMDUyNjU0WhcNMTcwODIxMDUyNjU0WjBKMQswCQYDVQQGEwJKUDEOMAwGA1UE
      CAwFVG9reW8xETAPBgNVBAoMCEZyYW5rNEREMRgwFgYDVQQDDA93d3cuZXhhbXBs
      ZS5jb20wXDANBgkqhkiG9w0BAQEFAANLADBIAkEAm/xmkHmEQrurE/0re/jeFRLl
      8ZPjBop7uLHhnia7lQG/5zDtZIUC3RVpqDSwBuw/NTweGyuP+o8AG98HxqxTBwID
      AQABMA0GCSqGSIb3DQEBBQUAA4GBABS2TLuBeTPmcaTaUW/LCB2NYOy8GMdzR1mx
      8iBIu2H6/E2tiY3RIevV2OW61qY2/XRQg7YPxx3ffeUugX9F4J/iPnnu1zAxxyBy
      2VguKv4SWjRFoRkIfIlHX0qVviMhSlNy2ioFLy7JcPZb+v3ftDGywUqcBiVDoea0
      Hn+GmxZA
      -----END CERTIFICATE-----
    TEST_CERT
  end

  describe "#common_name" do
    it "returns the common name" do
      expect(certificate.common_name).to eq("www.example.com")
    end
  end

  describe "#in_date?" do
    before do
      allow(Paypal::Util).to receive(:now).and_return(timestamp)
    end

    context "when the certificate is in date" do
      let(:timestamp) { Time.new(2016, 1, 1) }

      it { is_expected.to be_in_date }
    end

    context "when the certificate is not in date" do
      let(:timestamp) { Time.new(2020, 1, 1) }

      it { is_expected.not_to be_in_date }
    end
  end

  describe "#verify(algorithm:, signature:, fingerprint:)" do
    let(:algorithm) { "sha256" }
    let(:signature) { "signature" }
    let(:fingerprint) { "fingerprint" }

    let(:cert) { instance_double(OpenSSL::X509::Certificate, public_key:) }
    let(:public_key) { instance_double(OpenSSL::PKey::RSA) }

    before do
      allow(OpenSSL::X509::Certificate).to receive(:new).and_return(cert)
      allow(public_key).to receive(:verify_pss)
    end

    it "passes the inputs through to `verify_pss`" do
      certificate.verify(algorithm:, signature:, fingerprint:)

      expect(public_key).to have_received(:verify_pss).with(
        algorithm,
        signature,
        fingerprint,
        salt_length: :auto,
        mgf1_hash: algorithm,
      )
    end
  end
end
