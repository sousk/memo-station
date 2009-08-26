# Schema as of 2006/08/01 06:58:50 (schema version 9)
#
#  id                  :integer(11)   not null
#  sender_name         :string(255)   default(), not null
#  email               :string(255)   default(), not null
#  subject             :string(255)   default(), not null
#  message             :text          default(), not null
#  created_at          :datetime      
#  updated_at          :datetime      
#

class Mailmessage < ActiveRecord::Base
  validates_confirmation_of :email
  validates_presence_of :sender_name, :email, :email_confirmation, :subject, :message
end
