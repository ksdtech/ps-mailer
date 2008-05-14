class FamilyMailer < ActionMailer::Base
  def reg_form_invite(fam)
    recipients  fam.send_to 
    from        APP_CONFIG[:mail_from]
    subject     "Online Registration is Now Open"
    body        :family => fam
  end
end
