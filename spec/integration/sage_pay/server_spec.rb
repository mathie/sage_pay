require 'spec_helper'

if run_integration_specs?
  describe SagePay::Server, "integration specs" do
    before(:each) do
      SagePay::Server.default_registration_options = {
          :mode => :test,
          :vendor => TEST_VENDOR_NAME,
          :notification_url => TEST_NOTIFICATION_URL
      }
    end

    after(:each) do
      SagePay::Server.default_registration_options = {}
    end

    describe ".payment" do
      before(:each) do
        @payment = SagePay::Server.payment(
            :description => "Demo payment",
            :amount => 12.34,
            :currency => "GBP",
            :billing_address => address_factory
        )
      end

      it "should successfully register the payment with SagePay" do
        result = @payment.run!
        result.should_not be_nil
      end

      it "should be a valid registered payment" do
        registration = @payment.run!
        puts "Registration failed> #{registration}" unless registration.ok?
        registration.should be_ok
      end

      it "should have a next URL" do
        registration = @payment.run!
        next_url = registration.next_url
        puts "    Next URL given by gateway > #{next_url}" if next_url
        next_url.should_not be_nil
      end

      it "should allow us to follow the next URL and the response should be successful" do
        registration = @payment.run!
        uri = URI.parse(registration.next_url)
        request = Net::HTTP::Get.new(uri.request_uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        http.start { |http|
          http.request(request)
        }
      end

      it "should allow us to retrieve signature verification details" do
        @payment.run!
        sig_details = @payment.signature_verification_details

        sig_details.should_not                be_nil
        sig_details.security_key.should_not   be_nil
        sig_details.vendor.should_not         be_nil
      end
    end

    describe ".payment with a US address" do
      before(:each) do
        @payment = SagePay::Server.payment(
            :description => "Demo payment",
            :amount => 12.34,
            :currency => "GBP",
            :billing_address => address_factory(:country => "US", :state => "WY")
        )
      end

      it "should successfully register the payment with SagePay" do
        @payment.run!.should_not be_nil
      end

      it "should be a valid registered payment" do
        registration = @payment.run!
        registration.should be_ok
      end

      it "should have a next URL" do
        registration = @payment.run!
        next_url = registration.next_url
        puts "    Next URL given by gateway > #{next_url}" if next_url
        next_url.should_not be_nil
      end

      it "should allow us to follow the next URL and the response should be successful" do
        registration = @payment.run!
        uri = URI.parse(registration.next_url)
        request = Net::HTTP::Get.new(uri.request_uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        http.start { |http|
          http.request(request)
        }
      end

      it "should allow us to retrieve signature verification details" do
        @payment.run!
        sig_details = @payment.signature_verification_details

        sig_details.should_not                be_nil
        sig_details.security_key.should_not   be_nil
        sig_details.vendor.should_not         be_nil
      end
    end

    describe ".deferred" do
      before(:each) do
        @deferred = SagePay::Server.deferred(
            :description => "Demo payment",
            :amount => 12.34,
            :currency => "GBP",
            :billing_address => address_factory
        )
      end

      it "should successfully register the deferred payment with SagePay" do
        @deferred.run!.should_not be_nil
      end

      it "should be a valid deferred payment" do
        registration = @deferred.run!
        registration.should be_ok
      end

      it "should have a next URL" do
        registration = @deferred.run!
        puts registration.response.inspect
        next_url = registration.next_url
        puts "    Next URL given by gateway > #{next_url}" if next_url
        next_url.should_not be_nil
      end

      it "should allow us to follow the next URL and the response should be successful" do
        registration = @deferred.run!
        uri = URI.parse(registration.next_url)
        request = Net::HTTP::Get.new(uri.request_uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        http.start { |http|
          http.request(request)
        }
      end

      it "should allow us to retrieve signature verification details" do
        @deferred.run!
        sig_details = @deferred.signature_verification_details

        sig_details.should_not                be_nil
        sig_details.security_key.should_not   be_nil
        sig_details.vendor.should_not         be_nil
      end
    end

    describe ".token_registration" do
      before(:each) do
        @token_registration = SagePay::Server.token_registration(
            :currency => "GBP",
            :notification_url => TEST_NOTIFICATION_URL
        )
      end

      it "should successfully register the payment with SagePay" do
        result = @token_registration.run!
        result.should_not be_nil
      end

      it "should be a valid registered token" do
        registration = @token_registration.run!
        puts "Registration failed> #{registration}" unless registration.ok?
        registration.should be_ok
      end

      it "should have a next URL"  do
        ap @token_registration
        #
        registration = @token_registration.run!
        next_url = registration.next_url
        puts "    Next URL given by gateway > #{next_url}" if next_url
        next_url.should_not be_nil
      end

    end

    context ".authenticate and .authorize" do
      before(:each) do
        @authenticated_transaction= SagePay::Server.authenticate(
            :description => "Demo payment",
            :amount => 12.34,
            :currency => "GBP",
            :billing_address => address_factory
        )
      end

      it "should have a next URL", :focus do
        ap @authenticated_transaction
        #
        registration = @authenticated_transaction.run!
        next_url = registration.next_url
        puts "    Next URL given by gateway > #{next_url}" if next_url
        next_url.should_not be_nil
      end


      it "current_TEST change" do

        {
            "VPSProtocol" => "2.23",
            "TxType" => "AUTHENTICATE",
            "VendorTxCode" => "715deff0-3721-012f-37f9-001617b98af1",
            "VPSTxId" => "{795F8EFC-C681-4A64-BF71-500DE08BA0B1}",
            "Status" => "AUTHENTICATED",
            "StatusDetail" => "Simulator example AUTHENTICATED Notification Post",
            "GiftAid" => "0",
            "3DSecureStatus" => "OK",
            "CAVV" => "MNBMISVQ5FOJX3WIR4H1JV",
            "CardType" => "VISA",
            "Last4Digits" => "1362",
            "VPSSignature" => "1A7C418CB4733117C7C8202D86956329",
            "controller" => "notifications",
            "action" => "create"
        }

      end


    end

  end
end
