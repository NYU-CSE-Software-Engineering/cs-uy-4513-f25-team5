class CitiesController < ApplicationController
  def autocomplete
    query = params[:q]&.strip || ''
    
    return render json: [] if query.length < 2
    
    begin
      # Use Geobytes API - free, no API key required
      # Filter for US cities only
      require 'net/http'
      require 'uri'
      require 'json'
      
      uri = URI("http://gd.geobytes.com/AutoCompleteCity")
      uri.query = URI.encode_www_form(q: query, fq: 'US')
      
      response = Net::HTTP.get_response(uri)
      
      if response.is_a?(Net::HTTPSuccess)
        cities = JSON.parse(response.body)
        # Limit to 10 results for better performance
        render json: cities.first(10)
      else
        render json: []
      end
    rescue => e
      # Log error in development
      Rails.logger.error "City autocomplete error: #{e.message}" if Rails.env.development?
      render json: []
    end
  end
end
