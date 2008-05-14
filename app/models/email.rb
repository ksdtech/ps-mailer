class Email < ActiveRecord::Base
  belongs_to :family_campaign
  
  def on_success(result)
    family_campaign.increment(:sent) if family_campaign
  end
  
  def on_fatal(exception)
    family_campaign.increment(:fatal) if family_campaign
  end
  
  def on_purge(max_age)
    family_campaign.increment(:purged) if family_campaign
  end
end
