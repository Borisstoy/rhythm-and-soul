namespace :bandsintown do
  desc "Enriching events"
  task update_all: :environment do
    puts "Enqueuing events"
    BandsintownJob.perform_now
  end
end

namespace :songkick do
  desc "Enriching events"
  task update_all: :environment do
    puts "Enqueuing events"
    SongkickJob.perform_now
  end
end
