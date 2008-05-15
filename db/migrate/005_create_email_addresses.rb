class CreateEmailAddresses < ActiveRecord::Migration
  def self.up
    create_table :email_addresses do |t|
      t.integer :family_id
      t.string :address
      t.timestamps
    end
    add_index :email_addresses, :address, :unique => true
  end

  def self.down
    drop_table :email_addresses
  end
end
