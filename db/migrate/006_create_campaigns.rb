class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns do |t|
      t.string :mailer_class
      t.string :method
      t.timestamps
    end
  end

  def self.down
    drop_table :campaigns
  end
end
