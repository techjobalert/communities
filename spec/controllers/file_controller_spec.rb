require 'spec_helper'

describe FileController do

  describe "GET 'upload'" do
    it "returns http success" do
      get 'upload'
      response.should be_success
    end
  end

  describe "GET 'load'" do
    it "returns http success" do
      get 'load'
      response.should be_success
    end
  end

  describe "GET 'convert'" do
    it "returns http success" do
      get 'convert'
      response.should be_success
    end
  end

  describe "GET 'merge'" do
    it "returns http success" do
      get 'merge'
      response.should be_success
    end
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

end
