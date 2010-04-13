require 'spec_helper'

include SagePay::Server

describe TransactionNotificationResponse do
  it "should work straight from the factory" do
    lambda {
      transaction_notification_response_factory.should be_valid
    }.should_not raise_error
  end

  describe "validations" do
    it { validates_the_presence_of(:transaction_notification_response, :status) }
    it { validates_the_presence_of(:transaction_notification_response, :redirect_url) }

    it "validates the presence of the status_detail field only if the status is something other than OK" do
      transaction_notification_response = transaction_notification_response_factory(:status => :ok, :status_detail => nil)
      transaction_notification_response.should be_valid

      transaction_notification_response = transaction_notification_response_factory(:status => :invalid, :status_detail => "Invalid request!")
      transaction_notification_response.should be_valid

      transaction_notification_response = transaction_notification_response_factory(:status => :invalid, :status_detail => "")
      transaction_notification_response.should_not be_valid
      transaction_notification_response.errors.on(:status_detail).should include("can't be empty")
    end

    it { validates_the_length_of(:transaction_notification_response, :redirect_url,  :max => 255) }
    it { validates_the_length_of(:transaction_notification_response, :status_detail, :max => 255) }

    it "should allow the status to be one of :ok, :invalid or :error" do
      transaction_notification_response = transaction_notification_response_factory(:status => :ok)
      transaction_notification_response.should be_valid

      transaction_notification_response = transaction_notification_response_factory(:status => :invalid)
      transaction_notification_response.should be_valid

      transaction_notification_response = transaction_notification_response_factory(:status => :error)
      transaction_notification_response.should be_valid

      transaction_notification_response = transaction_notification_response_factory(:status => :chickens)
      transaction_notification_response.should_not be_valid
      transaction_notification_response.errors.on(:status).should include("is not in the list")
    end
  end

  describe "#response" do
    it "should produce the expected response for an OK status" do
      transaction_notification_response = transaction_notification_response_factory(
        :status => :ok,
        :redirect_url => "http://test.host/some/redirect",
        :status_detail => nil
      )
      transaction_notification_response.response.should == <<-RESPONSE.chomp
Status=OK
RedirectURL=http://test.host/some/redirect
      RESPONSE
    end

    it "should produce the expected response for an invalid status" do
      transaction_notification_response = transaction_notification_response_factory(
        :status => :invalid,
        :redirect_url => "http://test.host/some/redirect",
        :status_detail => "Totally didn't expect that notification, dude."
      )
      # FIXME: I'm asserting here that I don't have to URI-encode the body
      # here. OK?
      transaction_notification_response.response.should == <<-RESPONSE.chomp
Status=INVALID
RedirectURL=http://test.host/some/redirect
StatusDetail=Totally didn't expect that notification, dude.
      RESPONSE
    end
  end
end
