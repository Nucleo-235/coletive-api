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
#  trello_list_id :string
#  external_url   :string
#  last_synced_at :datetime
#  slug           :string
#

class TaskSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :slug, :description, :due_date, :completed, :assigned

  has_many :labels

  def labels
    object.task_labels.map { |task_label| task_label.label  }
  end
end
