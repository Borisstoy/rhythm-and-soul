namespace :event do
  desc "Enriching events"
  task update_all: :environment do
    puts "Enqueuing events"
    ApiJob.perform_now
  end
end
