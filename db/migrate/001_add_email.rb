class AddEmail < ActiveRecord::Migration
  def self.up
    create_table :emails, :force => true do |t|
      t.integer :family_campaign_id
      t.string  :to
      t.string  :from
      t.text    :mail
      t.integer :last_send_attempt, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :emails
  end
end
