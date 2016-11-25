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
#

class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :slug, :description, :documentation_url, :code_url, :assets_url, :tasks_count
  has_one :user
  has_one :info
  
  has_many :tasks
  has_many :members

  def info
    object.info if object.respond_to? :info
  end

  def tasks
    object.tasks.limit(10)
  end

  def tasks_count
    object.tasks.count
  end

  def members
    object.members.limit(10)
  end
end
