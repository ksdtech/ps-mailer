class EmailLog < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :family
end
