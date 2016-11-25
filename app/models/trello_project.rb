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

class TrelloProject < Project
  has_one :info, class_name: :TrelloProjectInfo, foreign_key: 'project_id', dependent: :destroy
  accepts_nested_attributes_for :info
  
  validates_associated :info
  validates_presence_of :info

  def sync
    trello_board = Trello::Board.from_response user.trello_client.get("/boards/#{info.board_id}")
    self.public = !trello_board.closed && trello_board.prefs["permissionLevel"] && trello_board.prefs["permissionLevel"] == "public"
    self.save
    
    # sync tasks
  end
end
