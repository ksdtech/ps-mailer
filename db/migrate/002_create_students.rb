class CreateStudents < ActiveRecord::Migration
  def self.up
    create_table :students, :id => false, :force => true do |t|
      t.integer :id
      t.string :last_name
      t.string :first_name
      t.integer :grade_level
      t.timestamps
    end
  end

  def self.down
    drop_table :students
  end
end
