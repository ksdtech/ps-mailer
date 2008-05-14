namespace :db do
  desc "Import family data into database"
  task :import => :environment do
    Family.import
  end
  
end