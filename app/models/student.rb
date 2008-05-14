class Student < ActiveRecord::Base
  has_many :family_students
  has_many :families, :through => :family_students
  
  def grade_level_s
    grade_level == 0 ? 'K' : grade_level.to_s
  end
  
end
