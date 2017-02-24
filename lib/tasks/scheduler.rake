desc "This task is called by the Heroku scheduler add-on"
task :update_all => :environment do
  puts "Updating events..."
  ApiJob.perform
  puts "done."
end

# task :send_reminders => :environment do
#   User.send_reminders
# end
