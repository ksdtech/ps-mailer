class Campaign < ActiveRecord::Base
  has_many :family_campaigns, :dependent => :destroy
  has_many :families, :through => :family_campaigns
  
  def queue_mail(fam)
    fc = nil
    count = 0
    if fam.email_addresses.empty?
      fc = family_campaigns.create(:family_id => fam.id, 
        :status => 'failed', :message => 'no email addresses')
    else
      klass = Object.const_get(self.mailer_class)
      mail = klass.send("create_#{self.method_name}", fam)
    
      # cribbed from ActionMailer::ARMailer
      mail.destinations.each do |destination|
        em = Email.create(:mail => mail.encoded, 
          :to => destination, :from => mail.from.first)
        fc = family_campaigns.create(:family_id => fam.id, 
            :status => 'pending') if fc.nil?
        count += 1
        fc.emails << em
        fc.update_attributes(:status => 'queued', :queued => count)
      end
    end
    puts "campaign #{self.id} queued #{count} messages for family #{fam.id}"
    fc
  end
end
