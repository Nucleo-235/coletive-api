# == Schema Information
#
# Table name: tasks
#
#  id             :integer          not null, primary key
#  project_id     :integer
#  type           :string
#  name           :string
#  description    :text
#  due_date       :datetime
#  completed      :boolean          default(FALSE)
#  assigned       :boolean          default(FALSE)
#  sort_order     :integer
#  trello_card_id :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Task < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :project, :name
end
