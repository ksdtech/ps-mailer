class Student < ActiveRecord::Base
  has_many :family_students, :dependent => :delete_all
  has_many :families, :through => :family_students
  
  def display
    "#{last_name.upcase}, #{first_name} (#{grade_level_s})"
  end
  
  def grade_level_s
    grade_level == 0 ? 'K' : grade_level.to_s
  end
  
end
