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

class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :slug, :description, :documentation_url, :code_url, :assets_url, :tasks_count
  has_one :user
  # has_one :info

  has_many :available_tasks, key: "tasks", serializer: TaskSerializer
  has_many :members

  def info
    object.info if object.respond_to? :info
  end

  def get_tasks
    tasks = object.available_tasks
    if @instance_options[:labels] && !@instance_options[:labels].empty?
      labels = @instance_options[:labels]
      tasks = tasks.joins(:task_labels).joins(task_labels: :label)
      tasks = tasks.where('lower(labels.name) in (?)', labels.map { |e| e.downcase  })

      task_columns = Task.column_names.map{|col| "tasks.#{col}"}
      tasks = tasks.group(task_columns)
      tasks = tasks.select(task_columns)
    end

    if @instance_options[:query].present?
      query = @instance_options[:query]
      tasks = tasks.where('lower(tasks.name) like ?', "%#{query.downcase}%")
    end
    tasks
  end

  def available_tasks
    get_tasks.limit(3)
  end

  def tasks_count
    get_tasks.length
  end

  def members
    object.members.limit(10)
  end
end
