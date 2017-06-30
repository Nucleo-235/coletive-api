class AddColorToLabel < ActiveRecord::Migration
  def change
    add_column :labels, :color_rgb, :string
    add_column :labels, :border_color_rgb, :string
    add_column :labels, :font_color_rgb, :string
  end
end
