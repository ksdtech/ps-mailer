class FamilyMailer < ActionMailer::Base
  def reg_form_invite(fam)
    recipients  fam.send_to 
    from        APP_CONFIG[:mail_from]
    subject     "Online Registration is Now Open"
    unless APP_CONFIG[:mail_reply_to].nil?
      headers   'Reply-To' => APP_CONFIG[:mail_reply_to]
    end
    body        :family => fam
  end
end
