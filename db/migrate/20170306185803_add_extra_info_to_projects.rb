class AddExtraInfoToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :extra_info, :text
  end
end
