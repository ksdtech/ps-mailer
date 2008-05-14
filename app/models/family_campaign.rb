class FamilyCampaign < ActiveRecord::Base
  belongs_to :family
  belongs_to :campaign
  has_many :emails
end
