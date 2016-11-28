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
#

class TrelloProject < Project
  has_one :info, class_name: :TrelloProjectInfo, foreign_key: 'project_id', dependent: :destroy
  accepts_nested_attributes_for :info
  
  validates_associated :info
  validates_presence_of :info

  after_create :check_for_sync

  def valid_tasks
    # overriden in trello projects
    self.tasks.where(trello_list_id: self.info.todo_list_id)
  end

  def sync
    trello_board = Trello::Board.from_response user.trello_client.get("/boards/#{info.board_id}")
    self.closed = trello_board.closed
    self.public = trello_board.prefs["permissionLevel"] && trello_board.prefs["permissionLevel"] == "public"
    self.save
    
    # sync tasks
    trello_cards = Trello::Card.from_response user.trello_client.get("/lists/#{info.todo_list_id}/cards")
    existing_tasks = valid_tasks.map { |e| e.id }
    trello_cards.each do |trello_card|
      task = self.tasks.find_by(type: TrelloTask.name, trello_card_id: trello_card.id)
      if task
        task.update_with_card(trello_card)
      else
        task = TrelloTask.create_with_card(self, trello_card)
      end
      existing_tasks.delete(task.id) if existing_tasks.include? task.id

      labels = []
      trello_card.labels.each do |trello_label|
        labels.push Label.find_or_create_by(name: trello_label.name)
      end

      existing_labels = task.task_labels.map { |e| e.label.name }
      labels.each do |label|
        created_label = task.task_labels.find_or_create_by(label: label)
        existing_labels.delete(label.name) if existing_labels.include? label.name
      end

      # remove labels que nao foram mais encontradas
      existing_labels.each do |not_found_label_name|
        task.task_labels.where(label: Label.find_by(name: not_found_label_name)).destroy_all
      end
    end

    # synca cards que eram validos mas nao apareceram
    existing_tasks.each do |task_id|
      task = Task.find(task_id)
      trello_card = Trello::Card.from_response user.trello_client.get("/cards/#{task.trello_card_id}")
      task.update_with_card(trello_card)
    end

    self.last_synced_at = Time.new
    self.save
  end

  def self.sync_project(project_id)
    TrelloProject.find(project_id).sync
  end

  private

    def check_for_sync
      TrelloProject.delay.sync_project(self.id)
    end
end
