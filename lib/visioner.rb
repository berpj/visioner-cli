require 'visioner/version'
require 'base64'
require 'net/http'
require 'json'
require 'exifr'
require 'optparse'

module Visioner

  def self.get_place(latitude, longitude, type)
    # Prepare request
    url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{latitude},#{longitude}"
    url = URI(url)
    req = Net::HTTP::Get.new(url)
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true

    # Get place
    place = 'unknown'
    res.start do |http|
      resp = http.request(req)
      json = JSON.parse(resp.body)
      if json && json['status'] == 'OK' && json['results'][0]['address_components'] && json['results'][0]['address_components'].select {|address_component| address_component['types'][0] == type }
        place = json['results'][0]['address_components'].select {|address_component| address_component['types'][0] == type }
        if place[0]
          place = place[0]['long_name']
          place = place.downcase.tr(" ", "-")
        end
      end
    end

    return place
  end

  def self.get_label(image_name)
    # Convert image to Base 64
    b64_data = Base64.encode64(File.open(image_name, "rb").read)

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

    label = 'unknown'
    res.start do |http|
      resp = http.request(req)
      json = JSON.parse(resp.body)
      if json && json["responses"] && json["responses"][0]["labelAnnotations"] && json["responses"][0]["labelAnnotations"][0]["description"]
        label = json['responses'][0]['labelAnnotations'][0]['description']
        label = label.tr(" ", "-")
      end
    end

    return label
  end

  def self.rename_all(images, options)
    images.each do |image_name|

      # Check file
      if ! File.readable?(image_name)
        puts "Error: can't read file. Continuing..."
        next
      elsif File.extname(image_name) != '.jpg'
        puts "Error: can only rename jpg files. Continuing..."
        next
      end

      label = ''
      if options[:format].include? 'label'
        label = self.get_label(image_name)
      end

      date = ''
      if options[:format].include? 'date'
        date = File.mtime(image_name).strftime('%m-%d-%Y') # Fallback
        exif = EXIFR::JPEG.new(image_name)
        date = exif.date_time_original.strftime('%m-%d-%Y') if exif && exif.date_time_original
      end

      country = ''
      if options[:format].include? 'country'
        country = 'unknown' # Fallback
        exif = EXIFR::JPEG.new(image_name)
        country = self.get_place(exif.gps.latitude, exif.gps.longitude, 'country') if exif && exif.gps_latitude && exif.gps_longitude
      end

      locality = ''
      if options[:format].include? 'locality'
        locality = 'unknown' # Fallback
        exif = EXIFR::JPEG.new(image_name)
        locality = self.get_place(exif.gps.latitude, exif.gps.longitude, 'locality') if exif && exif.gps_latitude && exif.gps_longitude
      end

      new_image_name = options[:format].dup
      new_image_name.sub! 'label', label
      new_image_name.sub! 'date', date
      new_image_name.sub! 'locality', locality
      new_image_name.sub! 'country', country

      counter = nil
      while File.exist?(File.dirname(image_name) + "/" + new_image_name + counter.to_s + File.extname(image_name)) do
        counter = 1 if counter == nil
        counter = counter.to_i + 1
      end

      puts "#{File.basename(image_name)} -> #{new_image_name + counter.to_s + File.extname(image_name)}"

      File.rename(image_name, File.dirname(image_name) + "/" + new_image_name + counter.to_s + File.extname(image_name))

    end
  end

end
