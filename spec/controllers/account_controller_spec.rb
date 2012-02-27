require 'spec_helper'

describe AccountController do

  describe "GET 'items'" do
    it "returns http success" do
      get 'items'
      response.should be_success
    end
  end

  describe "GET 'purchase'" do
    it "returns http success" do
      get 'purchase'
      response.should be_success
    end
  end

  describe "GET 'purchased_items'" do
    it "returns http success" do
      get 'purchased_items'
      response.should be_success
    end
  end

  describe "GET 'payments_info'" do
    it "returns http success" do
      get 'payments_info'
      response.should be_success
    end
  end

end
