class FamilyStudent < ActiveRecord::Base
  belongs_to :family
  belongs_to :student
  
  def last_name
    student.last_name
  end  
end
