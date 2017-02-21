

# Scraping of the ClassicTic website

from_day = "22"
from_month = "2017-02"
until_day = "22"
until_month = "2018-02"
city = "Paris"
search_page = 0

for search_page in (1..2)
  url = "https://www.classictic.com/fr/sitesearch/?search=&from_day=#{from_day}&from_month=#{from_month}&until_day=#{until_day}&until_month=#{until_month}&city=#{city}&page=#{search_page}"

  html_file = open(url)
  html_doc = Nokogiri::HTML(html_file)

  html_doc.css('.mod_event_info').each do |element|
    event_name = element.css('a').text.strip
    event_date = Time.parse(element.css('.date').text.gsub("Plus de dates", " ").gsub(".", "").strip)
    venue_name = element.css('.venue strong').text.strip
    venue_address = element.css('.venue').text.gsub(/\s+/, " ").strip

    venue = Venue.create!(name: venue_name, address: venue_address)
    event = Event.new(name: event_name, date: event_date)
    event.venue = venue
    event.save
    p "-- Event #{event_name} created --"
  end
end
