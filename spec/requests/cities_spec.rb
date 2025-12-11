require 'rails_helper'

RSpec.describe "Cities", type: :request do
  describe "GET /cities/autocomplete" do
    let(:path) { cities_autocomplete_path }

    it "returns empty array when query is too short" do
      get path, params: { q: 'a' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it "limits successful results to 10 entries" do
      response_double = Net::HTTPSuccess.new(1.0, '200', 'OK')
      allow(response_double).to receive(:body).and_return(JSON.dump((1..12).map { |i| "City#{i}" }))
      allow(Net::HTTP).to receive(:get_response).and_return(response_double)

      get path, params: { q: 'new' }

      parsed = JSON.parse(response.body)
      expect(parsed.length).to eq(10)
      expect(parsed).to eq((1..10).map { |i| "City#{i}" })
    end

    it "returns empty array on non-successful HTTP response" do
      failure_response = Net::HTTPServerError.new(1.0, '500', 'Error')
      allow(Net::HTTP).to receive(:get_response).and_return(failure_response)

      get path, params: { q: 'new' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it "returns empty array when an exception occurs" do
      allow(Net::HTTP).to receive(:get_response).and_raise(StandardError.new("boom"))

      get path, params: { q: 'new' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end
end

