desc "This task is called by the Heroku scheduler add-on"
task :update_all => :environment do
  puts "Updating events..."
  ApiJob.perform_now
  puts "done."
end

# task :send_reminders => :environment do
#   User.send_reminders
# end
