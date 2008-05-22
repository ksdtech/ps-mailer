class CreateEmailLogs < ActiveRecord::Migration
  def self.up
    create_table :email_logs do |t|
      t.integer :email_id
      t.integer :campaign_id
      t.integer :family_id
      t.string :to
      t.string :from
      t.string :result
      t.string :message
      t.timestamps
    end
  end

  def self.down
    drop_table :email_logs
  end
end
