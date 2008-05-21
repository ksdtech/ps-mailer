class FamilyMailer < ActionMailer::Base
  TEMPLATES = {
    :reg_form_invite =>     { :name => "Reg Invite", :subject => "Online Registration is Now Open" },
    :reg_form_reminder_1 => { :name => "Reminder 1", :subject => "Reminder: Please Complete your Online Registration" },
  }
  
  def method_missing(method_name, *args)
    if TEMPLATES.key?(method_name)
      setup_email(args.first, TEMPLATES[method_name][:subject])
      render :template => method_name
    else
      super
    end
  end

  protected
  
  def setup_email(fam, subj)
    recipients  fam.send_to 
    from        APP_CONFIG[:mail_from]
    subject     subj
    unless APP_CONFIG[:mail_reply_to].nil?
      headers   'Reply-To' => APP_CONFIG[:mail_reply_to]
    end
    body        :family => fam
  end

end
