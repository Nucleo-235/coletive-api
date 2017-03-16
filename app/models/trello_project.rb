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

class TrelloProject < Project
  has_one :info, class_name: :TrelloProjectInfo, foreign_key: 'project_id', dependent: :destroy
  accepts_nested_attributes_for :info
  
  validates_associated :info
  validates_presence_of :info

  after_create :check_for_sync

  def get_updated_cards
    actions = Trello::Action.from_response user.trello_client.get("/boards/#{info.board_id}/actions", { filter: TrelloUtils.cards_update_actions_to_s, since: self.last_synced_at.to_s })
    TrelloUtils.get_cards_from_actions(actions, user.trello_client)
  end

  def get_deleted_cards
    actions = Trello::Action.from_response user.trello_client.get("/boards/#{info.board_id}/actions", { filter: TrelloUtils.cards_delete_actions_to_s, since: self.last_synced_at.to_s })
    TrelloUtils.get_cards_from_actions(actions, user.trello_client)
  end

  def get_new_cards
    cards = Trello::Card.from_response user.trello_client.get("lists/#{info.todo_list_id}/cards", { })
    cards
  end

  def available_tasks
    # overriden in trello projects
    self.tasks.where(trello_list_id: self.info.todo_list_id)
  end

  def sync_project_only(trello_board = nil)
    lastSync = Time.new

    begin
      trello_board = Trello::Board.from_response user.trello_client.get("/boards/#{info.board_id}") if !trello_board || trello_board.id != info.board_id
      self.closed = trello_board.closed
      self.public = trello_board.prefs["permissionLevel"] && trello_board.prefs["permissionLevel"] == "public"
      self.last_synced_at = lastSync
      self.save
    rescue Trello::Error => ex
      # caso tenha sido removido
      if ex.message == "unauthorized permission requested"
        self.destroy
      else
        puts "Board " + self.name
        puts ex.inspect
        raise
      end
    end
  end

  def sync_tasks(trello_cards = nil)
    if !trello_cards
      if self.last_synced_at && self.tasks.length > 0
        trello_cards = get_updated_cards + get_deleted_cards
      else
        trello_cards = get_new_cards
      end
    end

    # sync tasks
    # existing_tasks = self.tasks.map { |e| e.id } - não descobri se era realmente necessario
    member_id = user.trello_member.id

    trello_cards.each do |trello_card|
      task = TrelloTask.sync_task(trello_card, self, member_id)
      # existing_tasks.delete(task.id) if (task && existing_tasks.include?(task.id)) - não descobri se era realmente necessario
      # no metodo de sync usamos isso para deletar tarefas que foram deletadas
    end
  end

  def sync
    sync_project_only
    sync_tasks
  end

  def self.update_or_create(board, user)
    project_info = TrelloProjectInfo.find_by(board_id: board.id)
    if !project_info
      project = TrelloProject.new({name: board.name, description: board.description, info_attributes: {board_id: board.id}})
      project.user = user
      project.save!
    else
      project = project_info.project
      project.sync_project_only(board)
    end
    project
  end

  private

    def check_for_sync
      TrelloProject.delay.sync_project(self.id)
    end
end
