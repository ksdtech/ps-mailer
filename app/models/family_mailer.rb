class FamilyMailer < ActionMailer::Base
  def reg_form_invite(fam)
    recipients  fam.send_to 
    from        APP_CONFIG[:mail_from]
    reply_to    APP_CONFIG[:mail_reply_to] unless APP_CONFIG[:mail_reply_to].nil?
    subject     "Online Registration is Now Open"
    body        :family => fam
  end
end
