class CreateTaskMembers < ActiveRecord::Migration
  def change
    create_table :task_members do |t|
      t.references :task, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :trello_member_id

      t.timestamps null: false
    end
  end
end
