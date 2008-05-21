class Student < ActiveRecord::Base
  has_many :family_students, :dependent => :destroy
  has_many :families, :through => :family_students
  before_save :update_completion_status
  
  def display
    "#{last_name.upcase}, #{first_name} (#{grade_level_s}) [#{completed_pages('', '')}]"
  end
  
  def incomplete_pages(delim=', ', nopages='None', allpages='All')
    s = []
    1.upto(9) do |i|
      s << i.to_s if self.send("form#{i}_updated_at").nil?
    end
    if s.empty? 
      return nopages
    elsif s.size == 9
      return allpages
    end
    s.join(delim)
  end
  
  def completed_pages(delim=', ', nopages='None', allpages='All')
    s = []
    1.upto(9) do |i|
      s << i.to_s if !self.send("form#{i}_updated_at").nil?
    end
    if s.empty? 
      return nopages
    elsif s.size == 9
      return allpages
    end
    s.join(delim)
  end
  
  def grade_level_s
    grade_level == 0 ? 'K' : grade_level.to_s
  end

  protected
  
  def update_completion_status
    self.reg_complete = (!self.reg_will_attend.blank? && self.reg_will_attend =~ /nr-/) ?
      !self.form1_updated_at.nil? : 
      (!self.form1_updated_at.nil? && !self.form2_updated_at.nil? && !self.form3_updated_at.nil? &&
      !self.form4_updated_at.nil? && !self.form5_updated_at.nil? && !self.form6_updated_at.nil? &&
      !self.form7_updated_at.nil? && !self.form8_updated_at.nil? && !self.form9_updated_at.nil?)
    true
  end
  
end
