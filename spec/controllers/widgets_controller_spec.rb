require 'spec_helper'

describe WidgetsController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'communities'" do
    it "returns http success" do
      get 'communities'
      response.should be_success
    end
  end

end
