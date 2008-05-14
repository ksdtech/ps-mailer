class CreateFamilies < ActiveRecord::Migration
  def self.up
    create_table :families, :id => false, :force => true do |t|
      t.integer :id
      t.string :password
      t.string :last_name
      t.timestamps
    end
  end

  def self.down
    drop_table :families
  end
end
