class CreateFamilies < ActiveRecord::Migration
  def self.up
    create_table :families, :id => false, :force => true do |t|
      t.integer :id
      t.string :password
      t.string :last_name
      t.timestamps
    end
    add_index :families, :id, :unique => true
    add_index :families, :password, :unique => true
  end

  def self.down
    drop_table :families
  end
end
