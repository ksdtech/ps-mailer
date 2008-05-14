class Family < ActiveRecord::Base
  has_many :family_students, :order => :grade_level
  has_many :family_campaigns
  has_many :campaigns, :through => :family_campaigns
  has_many :emails, :through => :family_campaigns
  has_many :email_addresses
  
  def add_student(st, un)
    family_students.create(:student_id => st.id, :grade_level => st.grade_level, :username => un)
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
  
  def last_name
    last_names = { }
    family_students.each do |fs| 
      last_names[fs.last_name] ||= 0
      last_names[fs.last_name] += 1
    end
    max_last = -1
    last_n = nil
    last_names.each do |ln, count|
      if count > max_last
        max_last = count
        last_n = ln
      end
    end
    last_n
  end
  
  def student_info
    info = ''
    family_students.each do |fs|
      info << "\n" if !info.empty?
      st = fs.student
      info << "     Student:   #{st.first_name} #{st.last_name} (#{st.grade_level_s})\n"
      info << "     User Name: #{fs.username}\n"
      info << "     Password:  #{self.password}\n"
    end
    info
  end
  
  def self.import(fname='family_data.txt', primary_only=true)
    fname = File.join(RAILS_ROOT, 'db', fname) unless fname[0, 1] == '/'
    FasterCSV.foreach(fname, :row_sep => "\n", :col_sep => "\t", :headers => true,
      :header_converters => :symbol) do |row|
        
      sn = row[:student_number]
      st = Student.new(:last_name => row[:last_name],
        :first_name => row[:first_name],
        :grade_level => row[:grade_level].to_i)
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
  end
  
  def self.queue_mail(method, mailer_class='FamilyMailer')
    c = Campaign.create(:mailer_class => mailer_class, 
      :method => method)
    any_mail_queued = false
    Family.find(:all).each do |fam|
      any_mail_queued = true if c.queue_mail(fam)
    end
    c.destroy unless any_mail_queued
  end
end
