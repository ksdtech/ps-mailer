namespace :mail do
  desc "Send queued mail from database"
  task :send_once => :environment do
    ActionMailer::ARSendmail2.run(["--once"])
  end
  
  desc "Show queued mail in database"
  task :mailq => :environment do
    ActionMailer::ARSendmail2.run(["--mailq"])
  end
end