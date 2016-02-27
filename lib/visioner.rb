require 'visioner/version'
require 'base64'
require 'net/http'
require 'json'

module Visioner

  def self.rename_all(images)
    images.each do |image|

      # Convert image to Base 64
      b64_data = Base64.encode64(File.open(image, "rb").read)

      # Prepare request
      api_key = ENV['GOOGLE_VISION_API_KEY']
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

      # Make request
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
        end
      end

      unless name.empty?
        puts "#{image} -> #{name + File.extname(image)}"
        File.rename(image, File.dirname(image) + "/" + name + File.extname(image))
      end

    end
  end

end
