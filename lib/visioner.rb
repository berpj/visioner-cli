require 'visioner/version'
require 'base64'
require 'net/http'
require 'json'
require 'exifr'
require 'optparse'

module Visioner

  def self.get_country(latitude, longitude)
    # Prepare request
    url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{latitude},#{longitude}"
    url = URI(url)
    req = Net::HTTP::Get.new(url)
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true

    # Get country
    country = 'unknown'
    res.start do |http|
      resp = http.request(req)
      json = JSON.parse(resp.body)
      if json && json['status'] == 'OK' && json['results'][0]['address_components'] && json['results'][0]['address_components'].select {|address_component| address_component['types'][0] == 'country' }
        country = json['results'][0]['address_components'].select {|address_component| address_component['types'][0] == 'country' }
        country = country[0]['long_name']
        country = country.downcase.tr(" ", "-")
      end
    end

    return country
  end

  def self.rename_all(images, options)
    images.each do |image_name|

      # Check file extension
      if File.extname(image_name) != '.jpg'
        puts "Error: can only rename jpg files. Continuing..."
        next
      end


      # Convert image to Base 64
      begin
        b64_data = Base64.encode64(File.open(image_name, "rb").read)
      rescue
        puts "Error: can't read file. Exiting..."
      end

      # Prepare request
      api_key = ENV['GOOGLE_API_KEY']
      content_type = "Content-Type: application/json"
      url = "https://vision.googleapis.com/v1/images:annotate?key=#{api_key}"
      data = {
        "requests": [
          {
            "image": {
              "content": b64_data
            },
            "features": [
              {
                "type": "LABEL_DETECTION",
                "maxResults": 1
              }
            ]
          }
        ]
      }.to_json
      url = URI(url)
      req = Net::HTTP::Post.new(url, initheader = {'Content-Type' =>'application/json'})
      req.body = data
      res = Net::HTTP.new(url.host, url.port)
      res.use_ssl = true

      # Rename file
      name = ""
      res.start do |http|
        resp = http.request(req)
        json = JSON.parse(resp.body)
        if json && json["responses"] && json["responses"][0]["labelAnnotations"] && json["responses"][0]["labelAnnotations"][0]["description"]
          name = json['responses'][0]['labelAnnotations'][0]['description']
          name = name.tr(" ", "-")
        end
      end

      unless name.empty?
        counter = nil
        while File.exist?(File.dirname(image_name) + "/" + name + counter.to_s + File.extname(image_name)) do
          counter = 1 if counter == nil
          counter = counter.to_i + 1
        end

        exif = EXIFR::JPEG.new(image_name)

        date = ''
        if options[:date]
          date = File.mtime(image_name).strftime('%m-%d-%Y') # Fallback
          date = exif.date_time_original.strftime('%m-%d-%Y') + '_' if exif.date_time_original
        end

        country = ''
        if options[:country]
          country = 'unknown' # Fallback
          country = self.get_country(exif.gps.latitude, exif.gps.longitude) + '_' if exif.gps_latitude && exif.gps_longitude
        end

        puts "#{image_name} -> #{country + date + name + counter.to_s + File.extname(image_name)}"

        File.rename(image_name, File.dirname(image_name) + "/" + country + date + name + counter.to_s + File.extname(image_name))
      end

    end
  end

end
