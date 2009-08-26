# Schema as of 2006/08/01 06:58:50 (schema version 9)
#
#  id                  :integer(11)   not null
#  user_id             :integer(10)   default(0), not null
#  name_kanji1         :string(255)   default(), not null
#  name_kanji2         :string(255)   default(), not null
#  pc_email            :string(255)   default(), not null
#  mobile_email        :string(255)   default(), not null
#  created_on          :datetime      
#  updated_on          :datetime      
#  karma               :integer(11)   default(0)
#

class UserInfo < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id
end
