# == Schema Information
#
# Table name: projects
#
#  id                :integer          not null, primary key
#  type              :string
#  name              :string           not null
#  slug              :string
#  user_id           :integer
#  description       :text
#  documentation_url :string
#  code_url          :string
#  assets_url        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  public            :boolean          default(TRUE)
#  last_synced_at    :datetime
#  closed            :boolean          default(FALSE)
#  extra_info        :text
#

require 'trello'

class Project < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  belongs_to :user
  validates_presence_of :name

  has_many :tasks, dependent: :destroy
  has_many :members, dependent: :destroy, class_name: :ProjectMember, foreign_key: 'project_id'

  scope :valid , -> do
    where(public: true, closed: false)
  end

  def valid_tasks
    # overriden in trello projects
    self.tasks
  end

  def sync
    
  end
end
