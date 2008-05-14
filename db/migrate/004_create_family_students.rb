class CreateFamilyStudents < ActiveRecord::Migration
  def self.up
    create_table :family_students, :force => true do |t|
      t.integer :student_id
      t.integer :family_id
      t.integer :grade_level
      t.string :username
      t.timestamps
    end
  end

  def self.down
    drop_table :family_students
  end
end
