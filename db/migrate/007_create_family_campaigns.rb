class CreateFamilyCampaigns < ActiveRecord::Migration
  def self.up
    create_table :family_campaigns do |t|
      t.integer :family_id
      t.integer :campaign_id
      t.string  :status
      t.string  :message
      t.integer :queued
      t.integer :sent
      t.integer :fatal
      t.integer :purged
      t.timestamps
    end
  end

  def self.down
    drop_table :family_campaigns
  end
end
