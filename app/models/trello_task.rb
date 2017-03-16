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
#

class TrelloTask < Task
  validates_presence_of :trello_card_id
  before_update :check_to_update_card

  def update_with_card(card)
    begin
      @trello_card = card
      self.name = card.name
      self.description = card.desc
      self.due_date = card.due
      self.completed = card.closed || (card.badges && card.badges["dueComplete"])
      self.assigned = card.member_ids.length > 0
      self.trello_list_id = card.list_id
      self.external_url = card.url

      self.save!
    ensure
      @trello_card = nil
    end
    self
  end

  def self.create_with_card(project, card)
    task = TrelloTask.new
    task.project = project
    task.trello_card_id = card.id
    task.update_with_card(card)
  end

  def self.is_valid?(trello_card, project, trello_member_id)
    true
  end

  def self.is_available?(trello_card, project, trello_member_id)
    if trello_card.list_id == project.info.todo_list_id
      return true
    else
      return false
    end
  end

  def self.sync_task(trello_card, project, trello_member_id)
    lastSync = Time.new

    # puts trello_card.inspect
    # logger.debug trello_card

    if trello_card.class.name == Trello::Card.name
      # valid = TrelloTask.is_valid?(trello_card, project, trello_member_id)
      # if valid
        task = project.tasks.find_by(type: TrelloTask.name, trello_card_id: trello_card.id)
        if task
          task.update_with_card(trello_card)
        elsif TrelloTask.is_available?(trello_card, project, trello_member_id)
          # só cria se o card tiver disponivel (no caso do coletive somente se tiver na lista correta)
          task = TrelloTask.create_with_card(project, trello_card)
        else
          return nil
        end

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
        TrelloTask.update_last_sync(task, lastSync)
      else
        task = project.tasks.find_by(type: TrelloTask.name, trello_card_id: trello_card.id)
        task.destroy if task && !valid # só apaga se na for valido
        # if task
        #   task.update_with_card(trello_card) 
        #   TrelloTask.update_last_sync(task, lastSync)
        # end
      end
    # else
    #   task = project.tasks.find_by(type: TrelloTask.name, trello_card_id: trello_card.id)
    #   task.destroy if task && trello_card.type == :deleted_card
    # end

    task
  end

  def trello_card
    Trello::Card.from_response project.user.trello_client.get("/cards/#{trello_card_id}")
  end

  def check_to_update_card
    if !@trello_card
      begin
        @trello_card = self.trello_card

        if @trello_card
          if @trello_card.due != self.due_date
            @trello_card.due = self.due_date
            @trello_card.client = project.user.trello_client
            @trello_card.save

            TrelloTask.sync_task(@trello_card, self.project, self.project.user.trello_member.id)
          end
        end
      ensure
        @trello_card = nil
      end
    end
  end

  private

    def self.update_last_sync(task, lastSync)
      task.last_synced_at = lastSync
      task.save
    end
end
