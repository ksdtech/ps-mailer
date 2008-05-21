class FamilyCampaign < ActiveRecord::Base
  belongs_to :family
  belongs_to :campaign
  has_many :emails, :dependent => :destroy
  
  def nice_date(date)
    date.strftime("%b %d %H:%M")
  end
  
  def display
    "#{campaign.method_name} #{nice_date(campaign.created_at)} (#{emails.count} emails)"
  end
end
