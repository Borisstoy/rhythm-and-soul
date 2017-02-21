# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "Destroy of all Events and Venues"

Venue.destroy_all
Event.destroy_all

puts "Creation of Venues and Events"


venue = Venue.create!(
{
  name: "Concrete",
}
)

event = Event.create!(
  {
    name: "Concrete: Objekt, Convextion aka ERP, Nicolas Lutz, Saoirse, Veron (Jacan & Darween)",
    venue_id: venue.id,
  }
)




venue = Venue.create!(
{
  name: "La Machine Du Moulin Rouge",
}
)

event = Event.create!(
  {
    name: "Open Minded presente: Culoe de Song, Mr Raoul K, Mawimbi",
    venue_id: venue.id,
  }
)




venue = Venue.create!(
{
  name: "Supersonic",
}
)

event = Event.create!(
  {
    name: "Zoll Nacht with Demuja, House Monkey Records & Zoll Projekt",
    venue_id: venue.id,
  }
)



venue = Venue.create!(
{
  name: "Flow Paris",
}
)

event = Event.create!(
  {
    name: "Belle Epoque! with Bedouin, Edouard!, Moon, Emmanuel Russ & Rozoo",
    venue_id: venue.id,
  }
)



venue = Venue.create!(
{
  name: "Nuits Fauves",
}
)

event = Event.create!(
  {
    name: "H A ï K U with Recondite, Mind Against, Andrew Weatherall, Lokier",
    venue_id: venue.id,
  }
)



venue = Venue.create!(
{
  name: "Rex Club",
}
)


event = Event.create!(
  {
    name: "Open Minded presente: Xosar, Low Jack, I-F, Eastel",
    venue_id: venue.id,
  }
)
