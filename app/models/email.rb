class Email < ActiveRecord::Base
  belongs_to :family_campaign

  def log_result(res, extra=nil)
    fid = nil
    cid = nil
    if family_campaign
      family_campaign.increment!(res)
      cid = family_campaign.campaign_id
      fid = family_campaign.family_id
    end
    extra = extra.to_s unless extra.nil?
    EmailLog.create(:email_id => id, :campaign_id => cid, :family_id => fid, 
      :from => self.from, :to => self.to, :result => res.to_s, :message => extra)
  end
  
  def on_success(result)
    log_result(:sent)
  end
  
  def on_fatal(exception)
    log_result(:fatal, exception)
  end
  
  def on_purge(max_age)
    log_result(:purged)
  end
end
