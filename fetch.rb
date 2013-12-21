require 'json'
require 'net/http'
require 'nokogiri'

user ||= 'user'
pass ||= 'password'

bbox = [
  -38.556757,
  140.83374,
  -29.113775,
  153.325195 
]

planning_alerts = URI.parse("http://api.planningalerts.org.au/applications.js?bottom_left_lat=#{bbox[0]}&bottom_left_lng=#{bbox[1]}&top_right_lat=#{bbox[2]}&top_right_lng=#{bbox[3]}")

existing_notes = URI.parse("http://api.openstreetmap.org/api/0.6/notes?bbox=#{bbox.join(',')}")


planning_data = JSON.parse(Net::HTTP.get_response(planning_alerts).body)
notes_data    = Nokogiri::XML(Net::HTTP.get_response(existing_notes).body)

planning_data[0..0].each do |item|
  application = item["application"]
  lat = application["lat"]
  lon = application["lng"]

  # unless notes_data.xpath("//node[@lat='#{lat}' and @lon='#{lon}']").any?


    note_description = []
    note_description << "A planning application was found, lodged #{application['date_received']} with #{application['authority']['full_name']}"
    note_description << "Description: #{application['description']}"
    note_description << "Link: #{application['info_url']}"
    note_description << "Please assess and re-survey this data"

    params = URI.encode_www_form({
      'lat' => lat, 
      'lon' => lon, 
      'text'=> note_description.join("\n")
    })
    response = Net::HTTP.post_form(
      URI("http://#{user}:#{pass}@api.openstreetmap.org/api/0.6/notes?#{params}"), 'q' => {},

      )

    puts response.body
  # end

  item["link"] = "http://www.openstreetmap.org/?mlat#{lat}&mlon=#{lon}#map=19/#{lat}/#{lon}"

  puts item.inspect
end
