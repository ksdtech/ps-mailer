namespace :db do
  desc "Import family data into database"
  task :import => :environment do
    Family.import
  end
  
  desc "Queue reg form invite letter"
  task :reg_form_invite => :environment do
    Family.queue_mail('reg_form_invite')
  end
  
end