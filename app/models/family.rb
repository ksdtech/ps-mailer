class Family < ActiveRecord::Base
  has_many :family_students, :order => :grade_level, :dependent => :destroy
  has_many :students, :through => :family_students
  has_many :family_campaigns, :order => :created_at, :dependent => :destroy
  has_many :campaigns, :through => :family_campaigns
  has_many :emails, :through => :family_campaigns
  has_many :email_addresses, :order => :address
  has_many :email_logs
  
  def to_s
    "#{self.id}: #{self.last_name}"
  end
  
  def add_student(st, un, update_cache=false)
    fs = family_students.find(:first, :conditions => ['student_id=? OR username=?', st.id, un])
    if fs.nil?
      fs = family_students.create(:student_id => st.id, :grade_level => st.grade_level, :username => un)
    else
      fs.update_attribute(:grade_level, st.grade_level)
    end
    cache_last_name(true) if update_cache
  end
  
  def add_email_address(em)
    if !em.nil? && em =~ /^[-_.a-z0-9]+\@[-_.a-z0-9]+\.[a-z]+$/i
      ea = EmailAddress.find_or_initialize_by_address(em.downcase)
      ea.family_id = self.id
      ea.save
    end
  end

  def send_to
    email_addresses.collect { |ea| ea.address }
  end
  
  def cache_last_name(force = false)
    if force || last_name.nil?
      last_names = { }
      family_students.each do |st|
        last_names[st.last_name] ||= 0
        last_names[st.last_name] += 1
      end
      max_last = -1
      last_n = nil
      last_names.each do |ln, count|
        if count > max_last
          max_last = count
          last_n = ln
        end
      end
      update_attribute(:last_name, last_n)
    end
    last_name
  end
  
  def student_info
    info = ''
    family_students.each do |fs|
      st = fs.student
      info << "\n" if !info.empty?
      info << "     Student:   #{st.first_name} #{st.last_name} (#{st.grade_level_s})\n"
      info << "     User Name: #{fs.username}\n"
      info << "     Password:  #{self.password}\n"
    end
    info
  end
  
  def incomplete_student_info
    info = ''
    family_students.each do |fs|
      st = fs.student
      incomplete_pages = st.incomplete_pages
      next if incomplete_pages.blank?
      info << "\n" if !info.empty?
      info << "     Student:   #{st.first_name} #{st.last_name} (#{st.grade_level_s})\n"
      info << "     User Name: #{fs.username}\n"
      info << "     Password:  #{self.password}\n"
      info << "     Completed Pages: #{st.completed_pages}\n"
      info << "     Incomplete Pages: #{incomplete_pages}\n"
    end
    info
  end
  
  def queue_mail(method_name)
    c = Campaign.create(:mailer_class => 'FamilyMailer', :method_name => method_name.to_s)
    fc = c.queue_mail(self)
    c.destroy if fc.nil?
    fc
  end
  
  FAMILY_DATA_FIELDS = %w{
student_number
last_name
first_name
grade_level
enroll_status
home_id
web_id
web_password
mother_email
mother_email2
father_email
father_email2
home2_id
student_web_id
student_web_password
mother2_email
mother2_email2
father2_email
father2_email2 
reg_will_attend
reg_grade_level
exitcode
form1_updated_at 
form2_updated_at 
form3_updated_at 
form4_updated_at 
form5_updated_at 
form6_updated_at 
form7_updated_at 
form8_updated_at 
form9_updated_at 
  }
  
  class << self
    def find_incomplete
      find(:all, :include => :students, :conditions => ['students.reg_complete<>1'])
    end
    
    def import(fname='family_data.txt', primary_only=true)
      puts "deleting all families and students"
      Family.delete_all
      Student.delete_all
      FamilyStudent.delete_all
    
      fname = File.join(RAILS_ROOT, 'db', fname) unless fname[0, 1] == '/'
      FasterCSV.foreach(fname, :row_sep => "\n", :col_sep => "\t", :headers => true,
        :header_converters => :symbol) do |row|
        
        sn = row[:student_number]
        st = Student.new(:last_name => row[:last_name],
          :first_name => row[:first_name],
          :grade_level => row[:grade_level].to_i,
          :reg_will_attend => row[:reg_will_attend],
          :reg_grade_level => row[:reg_grade_level].to_i,
          :exitcode => row[:exitcode],        
          :form1_updated_at => row[:form1_updated_at],
          :form2_updated_at => row[:form2_updated_at],
          :form3_updated_at => row[:form3_updated_at],
          :form4_updated_at => row[:form4_updated_at],
          :form5_updated_at => row[:form5_updated_at],
          :form6_updated_at => row[:form6_updated_at],
          :form7_updated_at => row[:form7_updated_at],
          :form8_updated_at => row[:form8_updated_at],
          :form9_updated_at => row[:form9_updated_at]
          )
        st.id = sn.to_i
        st.save
        puts "student #{sn}"

        h1 = row[:home_id]
        h2 = row[:home2_id]
        if !h1.nil? && h1.to_i != 0
          begin
            f = Family.find(h1.to_i)
          rescue
            f = Family.new
            f.id = h1.to_i
            puts "family1 #{h1}"
          end
          f.password = row[:web_password]
          f.save
          f.add_student(st, row[:web_id])
          f.add_email_address(row[:father_email])
          f.add_email_address(row[:father_email2])
          f.add_email_address(row[:mother_email])
          f.add_email_address(row[:mother_email2])
        end
        if !primary_only && !h2.nil? && h2.to_i != 0
          begin
            f = Family.find(h2.to_i)
          rescue
            f = Family.new
            f.id = h2.to_i
            puts "family2 #{h2}"
          end
          f.password = row[:student_web_password]
          f.save
          f.add_student(st, row[:student_web_id])
          f.add_email_address(row[:father2_email])
          f.add_email_address(row[:father2_email2])
          f.add_email_address(row[:mother2_email])
          f.add_email_address(row[:mother2_email2])
        end
      end
      cache_last_name
      # find orphaned families?
    end
  
    def cache_last_name
      Family.find(:all).each do |fam| 
        puts "caching last name for #{fam.id}"
        fam.cache_last_name(true)
      end
    end
  
    def queue_mail(method_name, coll=nil)
      c = Campaign.create(:mailer_class => 'FamilyMailer', :method_name => method_name.to_s)
      total_destinations = 0
      any_mail_queued = false
      coll = Family.find(:all) if coll.nil?
      coll.each do |fam|
        fc = c.queue_mail(fam)
        if !fc.nil?
          any_mail_queued = true
          total_destinations += fc.emails.count
        end
      end
      c.destroy unless any_mail_queued
      total_destinations
    end
  end
end
