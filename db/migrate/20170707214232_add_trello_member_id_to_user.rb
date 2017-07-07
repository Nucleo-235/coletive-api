class AddTrelloMemberIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :trello_member_id, :string
  end
end
