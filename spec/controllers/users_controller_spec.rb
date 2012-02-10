require 'spec_helper'

describe UsersController do

  describe "GET 'profile'" do
    it "returns http success" do
      get 'profile'
      response.should be_success
    end
  end

  describe "GET 'settings'" do
    it "returns http success" do
      get 'settings'
      response.should be_success
    end
  end

  describe "GET 'account'" do
    it "returns http success" do
      get 'account'
      response.should be_success
    end
  end

end
