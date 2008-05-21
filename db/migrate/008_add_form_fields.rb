class AddFormFields < ActiveRecord::Migration
  def self.up
    add_column :students, :reg_complete, :boolean, :null => false, :default => false
    add_column :students, :reg_valid, :boolean, :null => false, :default => false
    add_column :students, :reg_will_attend, :string
    add_column :students, :reg_grade_level, :integer
    add_column :students, :exitcode, :string
    add_column :students, :form1_updated_at, :datetime
    add_column :students, :form2_updated_at, :datetime
    add_column :students, :form3_updated_at, :datetime
    add_column :students, :form4_updated_at, :datetime
    add_column :students, :form5_updated_at, :datetime
    add_column :students, :form6_updated_at, :datetime
    add_column :students, :form7_updated_at, :datetime
    add_column :students, :form8_updated_at, :datetime
    add_column :students, :form9_updated_at, :datetime
  end

  def self.down
  end
end
