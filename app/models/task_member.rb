# == Schema Information
#
# Table name: task_members
#
#  id               :integer          not null, primary key
#  task_id          :integer
#  user_id          :integer
#  trello_member_id :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TaskMember < ActiveRecord::Base
  belongs_to :task
  belongs_to :user
end
